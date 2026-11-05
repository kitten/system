use crate::{Result, wrapping};
use ssh_key::{PrivateKey, PublicKey};
use std::env;
use std::ffi::{OsStr, OsString};
use std::fs;
use std::io::Read;
use std::os::fd::{AsRawFd, FromRawFd};
use std::os::unix::{net::UnixStream, process::CommandExt};
use std::path::{Path, PathBuf};
use std::process::{Child, Command, ExitStatus, Stdio};
use std::sync::{
    Arc,
    atomic::{AtomicBool, Ordering},
};
use std::thread;
use std::time::{Duration, Instant};

// The publication identity must remain usable for the entire supervised session.
const SESSION_TIMEOUT: u64 = 1200;
const SHUTDOWN_TIMEOUT: u64 = 5;

struct Process(Child);

impl Drop for Process {
    fn drop(&mut self) {
        let _ = self.0.kill();
        let _ = self.0.wait();
    }
}

fn wait(child: &mut Child, seconds: u64) -> Result<ExitStatus> {
    let deadline = Instant::now() + Duration::from_secs(seconds);
    loop {
        if let Some(status) = child.try_wait()? {
            return Ok(status);
        }
        if Instant::now() >= deadline {
            return Err("forwarding subprocess timed out".into());
        }
        thread::sleep(Duration::from_millis(10));
    }
}

struct Tools<'a> {
    home: &'a OsStr,
    ssh: &'a OsStr,
    agent: &'a OsStr,
}

impl Tools<'_> {
    fn command(&self, executable: &OsStr, socket: Option<&Path>) -> Command {
        let mut command = Command::new(executable);
        command
            .env_clear()
            .env("HOME", self.home)
            .env("LC_ALL", "C")
            .env("PATH", "/nonexistent")
            .env("SSH_ASKPASS_REQUIRE", "never");
        if let Some(socket) = socket {
            command.env("SSH_AUTH_SOCK", socket);
        }
        if let Ok(protocol) = env::var("GIT_PROTOCOL")
            && matches!(protocol.as_str(), "version=0" | "version=1" | "version=2")
        {
            command.env("GIT_PROTOCOL", protocol);
        }
        command
    }

    fn ssh(&self, socket: &Path, public: &[PathBuf], destination: &[OsString]) -> Command {
        let mut command = self.command(self.ssh, Some(socket));
        command.args(["-F", "/dev/null"]);
        for path in public {
            command.arg("-i").arg(path);
        }
        command
            .arg("-o")
            .arg(format!("IdentityAgent={}", socket.display()))
            .args([
                "-o",
                "IdentitiesOnly=yes",
                "-o",
                "BatchMode=yes",
                "-o",
                "ForwardAgent=no",
                "-S",
                "none",
                "-o",
                "StrictHostKeyChecking=yes",
            ])
            .args(destination);
        command
    }
}

struct Config<'a> {
    tools: Tools<'a>,
    authorized: Vec<PublicKey>,
    wrapped: Option<&'a Path>,
    destination: &'a [OsString],
}

impl<'a> Config<'a> {
    fn parse(arguments: &'a [OsString]) -> Result<Self> {
        let [_, home, ssh, agent, wrapped, remaining @ ..] = arguments else {
            return Err("invalid forwarding transport configuration".into());
        };
        let separator = remaining
            .iter()
            .position(|value| value == "--")
            .ok_or("missing forwarding transport arguments")?;
        let (authorized, destination) = remaining.split_at(separator);
        let destination = &destination[1..];
        validate_destination(destination)?;
        let authorized = authorized
            .iter()
            .map(|key| {
                PublicKey::from_openssh(key.to_str().ok_or("invalid authorized public key")?)
                    .map_err(|_| "invalid authorized public key".into())
            })
            .collect::<Result<Vec<_>>>()?;
        let wrapped = (!wrapped.is_empty()).then(|| Path::new(wrapped));
        Ok(Self {
            tools: Tools { home, ssh, agent },
            authorized,
            wrapped,
            destination,
        })
    }
}

// FD 3 carries only public setup messages and caller liveness. Git's stdin and
// stdout remain inherited, so the supervisor can own SSH without relaying its
// protocol or accepting private key material over this channel.
const CONTROL_FD: i32 = 3;

fn inherit_control(command: &mut Command, socket: &UnixStream) {
    let descriptor = socket.as_raw_fd();
    // SAFETY: the socket remains open until spawn completes. Only async-signal-
    // safe syscalls run after fork. Clear CLOEXEC on the dedicated child FD.
    unsafe {
        command.pre_exec(move || {
            if libc::dup2(descriptor, CONTROL_FD) < 0
                || libc::fcntl(CONTROL_FD, libc::F_SETFD, 0) < 0
            {
                return Err(std::io::Error::last_os_error());
            }
            Ok(())
        });
    }
}

fn receive_control() -> Result<UnixStream> {
    // SAFETY: transport-supervisor is launched with an owned socket at FD 3.
    // Validate it first; CLOEXEC prevents SSH/ssh-agent inheriting the channel.
    if unsafe { libc::fcntl(CONTROL_FD, libc::F_SETFD, libc::FD_CLOEXEC) } < 0 {
        return Err("missing supervisor control socket".into());
    }
    let socket = unsafe { UnixStream::from_raw_fd(CONTROL_FD) };
    socket.peer_addr()?;
    Ok(socket)
}

struct Supervisor {
    process: Process,
    control: Option<UnixStream>,
}

impl Drop for Supervisor {
    fn drop(&mut self) {
        drop(self.control.take());
        let _ = wait(&mut self.process.0, SHUTDOWN_TIMEOUT);
    }
}

fn source_socket() -> Result<PathBuf> {
    env::var_os("SSH_AUTH_SOCK")
        .filter(|value| !value.is_empty())
        .map(PathBuf::from)
        .ok_or_else(|| "onward publication requires a forwarded SSH agent".into())
}

struct Credential {
    public: Vec<PublicKey>,
    private: Option<PrivateKey>,
}

fn prepare(config: &Config<'_>, socket: &Path) -> Result<Credential> {
    let mut client = wrapping::connect(socket)?;
    // Select only identities outside the replacement set for direct SSH. Mixed
    // agents take this route without falling back to the wrapped credential.
    let offered = client
        .list_all_identities()
        .map_err(|_| "cannot list forwarded SSH identities")?
        .into_iter()
        .filter_map(|identity| match identity {
            ssh_agent_client_rs::Identity::PublicKey(key) => Some(key.into_owned()),
            _ => None,
        });
    let (listed, direct): (Vec<_>, Vec<_>) = offered.partition(|key| {
        config
            .authorized
            .iter()
            .any(|listed| listed.key_data() == key.key_data())
    });
    if !direct.is_empty() {
        return Ok(Credential {
            public: direct,
            private: None,
        });
    }
    let path = config
        .wrapped
        .ok_or("no wrapped publication key is configured for the forwarded identities")?;
    let bundle = wrapping::Bundle::read(fs::File::open(path)?)?;
    let mut source = None;
    for key in &listed {
        if bundle.metadata.matches(key)? {
            if source.is_some() {
                return Err("forwarded agent offered duplicate source identities".into());
            }
            source = Some(key);
        }
    }
    let source = source.ok_or("no authorized forwarded identity matches the wrapped key source")?;
    let plaintext = wrapping::decrypt(&bundle.metadata, &mut client, source, &bundle.ciphertext)?;
    let private = wrapping::parse_private(&plaintext)?;
    drop(plaintext);
    Ok(Credential {
        public: vec![private.public_key().clone()],
        private: Some(private),
    })
}

fn supervise(config: &Config<'_>) -> Result<()> {
    let mut control = receive_control()?;
    let stopping = Arc::new(AtomicBool::new(false));
    for signal in [
        signal_hook::consts::SIGTERM,
        signal_hook::consts::SIGHUP,
        signal_hook::consts::SIGINT,
    ] {
        signal_hook::flag::register(signal, Arc::clone(&stopping))?;
    }
    let disconnected = Arc::clone(&stopping);
    thread::spawn(move || {
        // The parent sends no data. EOF/error means its lifetime has ended.
        let _ = control.read(&mut [0]);
        disconnected.store(true, Ordering::Relaxed);
    });
    let deadline = Instant::now() + Duration::from_secs(SESSION_TIMEOUT);
    let source = source_socket()?;
    let Credential { public, private } = prepare(config, &source)?;
    if stopping.load(Ordering::Relaxed) {
        return Err("publication caller disconnected".into());
    }
    // All credential work and children live here. Drop SSH and the agent before
    // the directory; neither private keys nor derived secrets are written to it.
    let directory = tempfile::Builder::new()
        .prefix("git-forward-")
        .tempdir_in("/tmp")?;
    let public_files = public
        .into_iter()
        .enumerate()
        .map(|(index, mut key)| {
            key.set_comment("");
            let path = directory.path().join(format!("identity-{index}.pub"));
            fs::write(&path, key.to_openssh()? + "\n")?;
            Ok(path)
        })
        .collect::<Result<Vec<_>>>()?;
    let mut agent = None;
    let socket = if let Some(private) = private {
        let socket = directory.path().join("agent");
        let mut child = Process(
            config
                .tools
                .command(config.tools.agent, None)
                .args(["-D", "-a"])
                .arg(&socket)
                .arg("-t")
                .arg(SESSION_TIMEOUT.to_string())
                .stdin(Stdio::null())
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .spawn()?,
        );
        let startup_deadline = Instant::now() + Duration::from_secs(5);
        while wrapping::connect(&socket).is_err() {
            if child.0.try_wait()?.is_some()
                || stopping.load(Ordering::Relaxed)
                || Instant::now() >= startup_deadline
            {
                return Err("isolated publication agent failed to start".into());
            }
            thread::sleep(Duration::from_millis(10));
        }
        wrapping::connect(&socket)?
            .add_identity(&private)
            .map_err(|_| "cannot load isolated publication identity")?;
        agent = Some(child);
        socket
    } else {
        source
    };
    if stopping.load(Ordering::Relaxed) {
        return Err("publication caller disconnected".into());
    }
    let mut outbound = Process(
        config
            .tools
            .ssh(&socket, &public_files, config.destination)
            .spawn()?,
    );
    loop {
        if stopping.load(Ordering::Relaxed) || Instant::now() >= deadline {
            return Err("publication session interrupted or timed out".into());
        }
        if let Some(child) = &mut agent
            && child.0.try_wait()?.is_some()
        {
            return Err("publication agent exited unexpectedly".into());
        }
        if let Some(status) = outbound.0.try_wait()? {
            return if status.success() {
                Ok(())
            } else {
                Err("onward SSH operation failed".into())
            };
        }
        thread::sleep(Duration::from_millis(50));
    }
}

fn validate_destination(mut arguments: &[OsString]) -> Result<()> {
    // Repository-local URL rewrites must not turn this credential into authority
    // for another SSH host, or inject SSH options / arbitrary remote commands.
    while arguments.len() >= 2 && arguments[0] == "-o" && arguments[1] == "SendEnv=GIT_PROTOCOL" {
        arguments = &arguments[2..];
    }
    if arguments.len() != 2 || arguments[0] != "git@github.com" {
        return Err("forwarding credentials are restricted to GitHub Git operations".into());
    }
    let command = arguments[1]
        .to_str()
        .ok_or("invalid outbound Git command")?;
    let path = command
        .strip_prefix("git-upload-pack '")
        .or_else(|| command.strip_prefix("git-receive-pack '"))
        .and_then(|path| path.strip_suffix('\''))
        .ok_or("invalid outbound Git command")?;
    let parts: Vec<_> = path.split('/').collect();
    if parts.len() != 2
        || parts.iter().any(|part| {
            part.is_empty()
                || matches!(*part, "." | "..")
                || !part
                    .bytes()
                    .all(|byte| byte.is_ascii_alphanumeric() || b"._-".contains(&byte))
        })
    {
        return Err("invalid outbound GitHub repository".into());
    }
    Ok(())
}

pub fn run(arguments: &[OsString]) -> Result<()> {
    let config = Config::parse(arguments)?;
    if arguments
        .first()
        .is_some_and(|value| value == "transport-supervisor")
    {
        return supervise(&config);
    }
    let source = source_socket()?;
    let (control, inherited) = UnixStream::pair()?;
    let mut command = config
        .tools
        .command(env::current_exe()?.as_os_str(), Some(&source));
    command
        .arg("transport-supervisor")
        .args(&arguments[1..])
        .process_group(0);
    inherit_control(&mut command, &inherited);
    let process = Process(command.spawn()?);
    drop(inherited);
    let mut supervisor = Supervisor {
        process,
        control: Some(control),
    };
    if !wait(
        &mut supervisor.process.0,
        SESSION_TIMEOUT + SHUTDOWN_TIMEOUT,
    )?
    .success()
    {
        return Err("onward SSH authentication or Git operation failed".into());
    }
    Ok(())
}
