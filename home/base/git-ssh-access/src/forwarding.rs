use crate::{Result, wrapping};
use ssh_key::{PrivateKey, PublicKey};
use std::env;
use std::ffi::{OsStr, OsString};
use std::fs;
use std::io::{BufRead, BufReader, Read, Write};
use std::os::fd::{AsRawFd, FromRawFd};
use std::os::unix::{net::UnixStream, process::CommandExt};
use std::path::{Path, PathBuf};
use std::process::{Child, Command, ExitStatus, Stdio};
use std::sync::{
    Arc,
    atomic::{AtomicBool, Ordering},
    mpsc,
};
use std::thread;
use std::time::{Duration, Instant};

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

    fn ssh(&self, socket: &Path, public: &Path, destination: &[OsString]) -> Command {
        let mut command = self.command(self.ssh, Some(socket));
        command
            .args(["-F", "/dev/null", "-i"])
            .arg(public)
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

enum Credential<'a> {
    Direct,
    Wrapped {
        ciphertext: &'a Path,
        metadata: &'a Path,
        publication: &'a Path,
    },
}

struct Identity<'a> {
    source_file: &'a Path,
    source: PublicKey,
    credential: Credential<'a>,
}

struct Config<'a> {
    tools: Tools<'a>,
    identities: Vec<Identity<'a>>,
    destination: &'a [OsString],
}

impl<'a> Config<'a> {
    fn parse(arguments: &'a [OsString]) -> Result<Self> {
        let [_, home, ssh, agent, rest @ ..] = arguments else {
            return Err("invalid forwarding transport configuration".into());
        };
        let separator = rest
            .iter()
            .position(|value| value == "--")
            .ok_or("missing forwarding transport arguments")?;
        let (identities, tail) = rest.split_at(separator);
        let destination = &tail[1..];
        validate_destination(destination)?;
        let (groups, remainder) = identities.as_chunks::<4>();
        if !remainder.is_empty() {
            return Err("invalid forwarding identity configuration".into());
        }
        let identities = groups
            .iter()
            .map(|[source, ciphertext, metadata, publication]| {
                let credential = if ciphertext.is_empty()
                    && metadata.is_empty()
                    && publication.is_empty()
                {
                    Credential::Direct
                } else if !ciphertext.is_empty() && !metadata.is_empty() && !publication.is_empty()
                {
                    Credential::Wrapped {
                        ciphertext: Path::new(ciphertext),
                        metadata: Path::new(metadata),
                        publication: Path::new(publication),
                    }
                } else {
                    return Err(
                        "wrapped credentials need ciphertext, metadata, and publication identity"
                            .into(),
                    );
                };
                Ok(Identity {
                    source_file: Path::new(source),
                    source: wrapping::read_public(Path::new(source))?,
                    credential,
                })
            })
            .collect::<Result<_>>()?;
        Ok(Self {
            tools: Tools { home, ssh, agent },
            identities,
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

struct Session {
    supervisor: Process,
    control: Option<UnixStream>,
    socket: PathBuf,
}

impl Session {
    fn new(
        config: &Config<'_>,
        source_socket: &Path,
        publication: &Path,
        wrapped: bool,
    ) -> Result<Self> {
        let (control, inherited) = UnixStream::pair()?;
        control.set_read_timeout(Some(Duration::from_secs(10)))?;
        control.set_write_timeout(Some(Duration::from_secs(5)))?;
        let mut command = config.tools.command(env::current_exe()?.as_os_str(), None);
        command
            .arg("transport-supervisor")
            .arg(config.tools.home)
            .arg(config.tools.ssh)
            .arg(if wrapped {
                config.tools.agent
            } else {
                OsStr::new("")
            })
            .arg(source_socket)
            .arg(publication)
            .arg("--")
            .args(config.destination)
            // Session-wide signals to the caller must leave its watchdog alive.
            .process_group(0);
        inherit_control(&mut command, &inherited);
        let supervisor = Process(command.spawn()?);
        drop(inherited);
        let mut session = Self {
            supervisor,
            control: Some(control),
            socket: PathBuf::new(),
        };
        let mut socket = String::new();
        BufReader::new(session.control.as_ref().unwrap())
            .take(4096)
            .read_line(&mut socket)?;
        if !socket.ends_with('\n') {
            return Err("publication supervisor failed to start".into());
        }
        session.socket = PathBuf::from(socket.trim_end_matches('\n'));
        Ok(session)
    }

    fn run(mut self) -> Result<()> {
        self.control.as_mut().unwrap().write_all(b"start\n")?;
        if !wait(&mut self.supervisor.0, 1205)?.success() {
            return Err("onward SSH authentication or Git operation failed".into());
        }
        Ok(())
    }
}

impl Drop for Session {
    fn drop(&mut self) {
        drop(self.control.take());
        let _ = wait(&mut self.supervisor.0, 5);
    }
}

fn supervise(arguments: &[OsString]) -> Result<()> {
    let [
        _,
        home,
        ssh,
        agent_executable,
        source_socket,
        public,
        separator,
        destination @ ..,
    ] = arguments
    else {
        return Err("invalid publication supervisor arguments".into());
    };
    if separator != "--" {
        return Err("missing supervisor destination".into());
    }
    validate_destination(destination)?;
    let tools = Tools {
        home,
        ssh,
        agent: agent_executable,
    };
    let mut control = receive_control()?;
    let stopping = Arc::new(AtomicBool::new(false));
    for signal in [
        signal_hook::consts::SIGTERM,
        signal_hook::consts::SIGHUP,
        signal_hook::consts::SIGINT,
    ] {
        signal_hook::flag::register(signal, Arc::clone(&stopping))?;
    }
    // The supervisor alone owns the directory, agent, and SSH child. Their drop
    // order stops SSH and the agent before removing the private runtime files.
    let directory = tempfile::Builder::new()
        .prefix("git-forward-")
        .tempdir_in("/tmp")?;
    let mut agent = None;
    let socket = if agent_executable.is_empty() {
        PathBuf::from(source_socket)
    } else {
        let socket = directory.path().join("agent");
        let mut child = Process(
            tools
                .command(agent_executable, None)
                .args(["-D", "-a"])
                .arg(&socket)
                .args(["-t", "60"])
                .stdin(Stdio::null())
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .spawn()?,
        );
        let deadline = Instant::now() + Duration::from_secs(5);
        while !socket.exists() {
            if child.0.try_wait()?.is_some()
                || stopping.load(Ordering::Relaxed)
                || Instant::now() >= deadline
            {
                return Err("isolated publication agent failed to start".into());
            }
            thread::sleep(Duration::from_millis(10));
        }
        agent = Some(child);
        socket
    };
    writeln!(control, "{}", socket.display())?;
    let (sender, receiver) = mpsc::channel();
    thread::spawn(move || {
        let mut input = BufReader::new(control);
        let mut line = String::new();
        if input.read_line(&mut line).is_ok() && line == "start\n" {
            let _ = sender.send(true);
            line.clear();
            let _ = input.read_line(&mut line);
        }
        let _ = sender.send(false);
    });
    let mut outbound = None;
    let deadline = Instant::now() + Duration::from_secs(1200);
    loop {
        if stopping.load(Ordering::Relaxed) || Instant::now() >= deadline {
            return Err("publication session interrupted or timed out".into());
        }
        if let Some(child) = &mut agent
            && child.0.try_wait()?.is_some()
        {
            return Err("publication agent exited unexpectedly".into());
        }
        if let Some(Process(child)) = &mut outbound
            && let Some(status) = child.try_wait()?
        {
            return if status.success() {
                Ok(())
            } else {
                Err("onward SSH operation failed".into())
            };
        }
        match receiver.recv_timeout(Duration::from_millis(50)) {
            Ok(true) if outbound.is_none() => {
                outbound = Some(Process(
                    tools.ssh(&socket, Path::new(public), destination).spawn()?,
                ));
            }
            Ok(_) | Err(mpsc::RecvTimeoutError::Disconnected) => {
                return Err("publication caller disconnected".into());
            }
            Err(mpsc::RecvTimeoutError::Timeout) => {}
        }
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
    if arguments
        .first()
        .is_some_and(|value| value == "transport-supervisor")
    {
        return supervise(arguments);
    }
    let config = Config::parse(arguments)?;
    let socket = env::var_os("SSH_AUTH_SOCK")
        .filter(|value| !value.is_empty())
        .ok_or("onward publication requires a forwarded SSH agent")?;
    let socket = Path::new(&socket);
    let mut client = wrapping::connect(socket)?;
    let offered = client
        .list_all_identities()
        .map_err(|_| "cannot list forwarded SSH identities")?;
    let mut matches = config.identities.iter().filter(|identity| offered.iter().any(|offered|
        matches!(offered, ssh_agent_client_rs::Identity::PublicKey(key) if key.key_data() == identity.source.key_data())
    ));
    let identity = matches
        .next()
        .ok_or("forwarded agent must offer exactly one configured identity")?;
    if matches.next().is_some() {
        return Err("forwarded agent must offer exactly one configured identity".into());
    }
    match &identity.credential {
        Credential::Direct => Session::new(&config, socket, identity.source_file, false)?.run(),
        Credential::Wrapped {
            ciphertext,
            metadata,
            publication,
        } => {
            let metadata = wrapping::Metadata::parse(&fs::read_to_string(metadata)?)?;
            let ciphertext = fs::read(ciphertext)?;
            if ciphertext.len() > 1024 * 1024 + 4096 {
                return Err("wrapped credential exceeds size limit".into());
            }
            let plaintext =
                wrapping::decrypt(&metadata, &mut client, &identity.source, &ciphertext)?;
            let private = PrivateKey::from_openssh(&*plaintext)
                .map_err(|_| "unwrapped credential is not an unencrypted OpenSSH private key")?;
            drop(plaintext);
            let expected = wrapping::read_public(publication)?;
            if private.is_encrypted() || private.public_key().key_data() != expected.key_data() {
                return Err(
                    "unwrapped publication key does not match configured public key".into(),
                );
            }
            let session = Session::new(&config, socket, publication, true)?;
            wrapping::connect(&session.socket)?
                .add_identity(&private)
                .map_err(|_| "cannot load isolated publication identity")?;
            drop(private);
            session.run()
        }
    }
}
