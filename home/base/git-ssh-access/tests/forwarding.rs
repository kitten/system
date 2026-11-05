use git_ssh_access::wrapping::{self, Bundle, Metadata};
use rand::rngs::OsRng;
use ssh_agent_client_rs::Client;
use ssh_key::{Algorithm, LineEnding, PrivateKey};
use std::fs;
use std::io::Write;
use std::os::unix::fs::PermissionsExt;
use std::os::unix::process::CommandExt;
use std::path::{Path, PathBuf};
use std::process::{Child, Command, Output, Stdio};
use std::thread;
use std::time::{Duration, Instant};
use tempfile::TempDir;

fn tool(name: &str) -> PathBuf {
    std::env::split_paths(&std::env::var_os("PATH").unwrap())
        .map(|path| path.join(name))
        .find(|path| path.is_file())
        .unwrap_or_else(|| panic!("missing test dependency: {name}"))
}

struct Fixture {
    directory: TempDir,
    agent: Child,
    socket: PathBuf,
    source: PrivateKey,
    publication: PrivateKey,
}

impl Fixture {
    fn new() -> Self {
        // Keep Unix socket paths within Darwin's sun_path limit.
        let directory = tempfile::Builder::new()
            .prefix("git-forward-test-")
            .tempdir_in("/tmp")
            .unwrap();
        let socket = directory.path().join("source-agent");
        let agent = Command::new(tool("ssh-agent"))
            .args(["-D", "-a"])
            .arg(&socket)
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
            .unwrap();
        let source = PrivateKey::random(&mut OsRng, Algorithm::Ed25519).unwrap();
        let publication = PrivateKey::random(&mut OsRng, Algorithm::Ed25519).unwrap();
        let fixture = Self {
            directory,
            agent,
            socket,
            source,
            publication,
        };
        let deadline = Instant::now() + Duration::from_secs(5);
        while wrapping::connect(&fixture.socket).is_err() {
            assert!(Instant::now() < deadline, "source agent did not start");
            thread::sleep(Duration::from_millis(10));
        }
        fixture.client().add_identity(&fixture.source).unwrap();
        fs::write(
            fixture.path("source.pub"),
            fixture.source.public_key().to_openssh().unwrap(),
        )
        .unwrap();
        fs::write(
            fixture.path("publication.pub"),
            fixture.publication.public_key().to_openssh().unwrap(),
        )
        .unwrap();
        fixture
    }

    fn path(&self, name: &str) -> PathBuf {
        self.directory.path().join(name)
    }
    fn client(&self) -> Client {
        wrapping::connect(&self.socket).unwrap()
    }

    fn command(&self) -> Command {
        let mut command = Command::new(env!("CARGO_BIN_EXE_git-ssh-access"));
        command.env_clear().env("SSH_AUTH_SOCK", &self.socket);
        command
    }

    fn wrap(&self) -> Bundle {
        let private = self.publication.to_openssh(LineEnding::LF).unwrap();
        let bundle = Bundle::wrap(
            &mut self.client(),
            self.source.public_key(),
            private.as_bytes(),
        )
        .unwrap();
        bundle
            .write(fs::File::create(self.path("wrapped")).unwrap())
            .unwrap();
        bundle
    }

    fn transport(&self, authorized: &str, wrapped: &str, ssh: &Path) -> Command {
        let mut command = self.command();
        let authorized = if authorized.is_empty() {
            Vec::new()
        } else {
            vec![fs::read_to_string(self.path(authorized)).unwrap()]
        };
        let wrapped = if wrapped.is_empty() {
            PathBuf::new()
        } else {
            self.path(wrapped)
        };
        command
            .arg("transport")
            .arg(self.directory.path())
            .arg(ssh)
            .arg(tool("ssh-agent"))
            .arg(wrapped)
            .args(authorized)
            .arg("--")
            .arg("git@github.com")
            .arg("git-upload-pack 'owner/repo.git'");
        command
    }

    fn stub(&self) -> PathBuf {
        let path = self.path("ssh-stub");
        // Report the explicit public-key selection and agent socket; check the
        // outbound options without contacting GitHub.
        fs::write(&path, format!("#!{}\ncase \"$*\" in *'ForwardAgent=no'*'StrictHostKeyChecking=yes'*) ;; *) exit 9;; esac\nprintf '%s\\n' \"$SSH_AUTH_SOCK\" >&2\nwhile [ \"$#\" -gt 0 ]; do if [ \"$1\" = -i ]; then shift; {} \"$1\"; fi; shift; done\n", tool("sh").display(), tool("cat").display())).unwrap();
        fs::set_permissions(&path, fs::Permissions::from_mode(0o700)).unwrap();
        path
    }
}

impl Drop for Fixture {
    fn drop(&mut self) {
        let _ = self.agent.kill();
        let _ = self.agent.wait();
    }
}

fn pipe(mut command: Command, input: &[u8]) -> Output {
    let mut child = command
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    child.stdin.take().unwrap().write_all(input).unwrap();
    child.wait_with_output().unwrap()
}

#[test]
fn wrapping_round_trip_and_wrong_identity_or_corrupt_ciphertext_fail() {
    let fixture = Fixture::new();
    let metadata = fixture.wrap().metadata;
    let ciphertext = Bundle::read(fs::File::open(fixture.path("wrapped")).unwrap())
        .unwrap()
        .ciphertext;
    let plaintext = wrapping::decrypt(
        &metadata,
        &mut fixture.client(),
        fixture.source.public_key(),
        &ciphertext,
    )
    .unwrap();
    assert!(
        PrivateKey::from_openssh(&*plaintext).unwrap().public_key()
            == fixture.publication.public_key()
    );
    assert!(
        metadata
            .derive(&mut fixture.client(), fixture.publication.public_key())
            .is_err()
    );
    let mut corrupted = ciphertext.clone();
    *corrupted.last_mut().unwrap() ^= 1;
    assert!(
        wrapping::decrypt(
            &metadata,
            &mut fixture.client(),
            fixture.source.public_key(),
            &corrupted
        )
        .is_err()
    );
    assert!(
        wrapping::decrypt(
            &metadata,
            &mut fixture.client(),
            fixture.source.public_key(),
            &ciphertext[..ciphertext.len() - 1]
        )
        .is_err()
    );
    fixture.client().remove_all_identities().unwrap();
    assert!(
        wrapping::decrypt(
            &metadata,
            &mut fixture.client(),
            fixture.source.public_key(),
            &ciphertext
        )
        .is_err()
    );
}

#[test]
fn metadata_checksum_version_and_key_type_are_validated() {
    let fixture = Fixture::new();
    let metadata = fixture.wrap().metadata;
    let encoded = metadata.encode().unwrap();
    assert!(Metadata::parse(&format!("# public metadata\n{encoded}\n")).is_ok());
    let mut corrupt = encoded.into_bytes();
    let last = corrupt.len() - 1;
    corrupt[last] = if corrupt[last] == b'Q' { b'P' } else { b'Q' };
    assert!(Metadata::parse(std::str::from_utf8(&corrupt).unwrap()).is_err());
    assert!(Metadata::parse("AGE-PLUGIN-SSHAGENT-1BAD").is_err());
    assert!(Metadata::parse("identity1\nidentity2").is_err());
    let mut unknown_version = vec![0; 49];
    unknown_version[0] = 2;
    let unknown_version = bech32::encode::<bech32::Bech32>(
        bech32::Hrp::parse("age-plugin-sshagent-").unwrap(),
        &unknown_version,
    )
    .unwrap();
    assert!(Metadata::parse(&unknown_version).is_err());
    let ecdsa = PrivateKey::random(
        &mut OsRng,
        Algorithm::Ecdsa {
            curve: ssh_key::EcdsaCurve::NistP256,
        },
    )
    .unwrap();
    assert!(Metadata::generate(ecdsa.public_key()).is_err());
}

#[test]
fn concurrent_transports_use_distinct_agents_and_reject_other_destinations() {
    let fixture = Fixture::new();
    fixture.wrap();
    let stub = fixture.stub();
    let first = fixture
        .transport("source.pub", "wrapped", &stub)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    let second = fixture
        .transport("source.pub", "wrapped", &stub)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    let first = first.wait_with_output().unwrap();
    let second = second.wait_with_output().unwrap();
    assert!(first.status.success() && second.status.success());
    assert_ne!(
        first.stderr, second.stderr,
        "concurrent sends shared a publication socket"
    );
    let mut invalid = fixture.command();
    invalid
        .arg("transport")
        .arg(fixture.directory.path())
        .arg(&stub)
        .arg(tool("ssh-agent"))
        .arg("")
        .arg("--")
        .arg("git@attacker.invalid")
        .arg("git-upload-pack 'owner/repo.git'");
    let result = invalid.output().unwrap();
    assert!(!result.status.success());
    assert!(String::from_utf8_lossy(&result.stderr).contains("restricted to GitHub"));
}

#[test]
fn cli_provisioning_is_a_self_contained_round_trip() {
    let fixture = Fixture::new();
    let private = fixture.publication.to_openssh(LineEnding::LF).unwrap();
    let mut wrap = fixture.command();
    wrap.arg("wrap");
    let encrypted = pipe(wrap, private.as_bytes());
    assert!(
        encrypted.status.success(),
        "{}",
        String::from_utf8_lossy(&encrypted.stderr)
    );
    let mut unwrap = fixture.command();
    unwrap.arg("unwrap");
    let decrypted = pipe(unwrap, &encrypted.stdout);
    assert!(
        decrypted.status.success(),
        "{}",
        String::from_utf8_lossy(&decrypted.stderr)
    );
    assert!(decrypted.stdout == private.as_bytes());
    fixture.client().remove_all_identities().unwrap();
    let mut unwrap = fixture.command();
    unwrap.arg("unwrap");
    assert!(!pipe(unwrap, &encrypted.stdout).status.success());
}

#[test]
fn wrapping_requires_an_unambiguous_supported_identity_or_explicit_selection() {
    let fixture = Fixture::new();
    let private = fixture.publication.to_openssh(LineEnding::LF).unwrap();
    let ecdsa = PrivateKey::random(
        &mut OsRng,
        Algorithm::Ecdsa {
            curve: ssh_key::EcdsaCurve::NistP256,
        },
    )
    .unwrap();
    fixture.client().add_identity(&ecdsa).unwrap();
    let mut automatic = fixture.command();
    automatic.arg("wrap");
    // Unsupported keys do not make the sole supported identity ambiguous.
    assert!(pipe(automatic, private.as_bytes()).status.success());
    fixture.client().add_identity(&fixture.publication).unwrap();
    let mut ambiguous = fixture.command();
    ambiguous.arg("wrap");
    let output = pipe(ambiguous, private.as_bytes());
    assert!(!output.status.success() && output.stdout.is_empty());
    assert!(String::from_utf8_lossy(&output.stderr).contains("select one with -i"));
    let mut explicit = fixture.command();
    explicit
        .args(["wrap", "-i"])
        .arg(fixture.path("source.pub"));
    let output = pipe(explicit, private.as_bytes());
    assert!(output.status.success());
    let bundle = Bundle::read(&output.stdout[..]).unwrap();
    assert!(
        bundle
            .metadata
            .matches(fixture.source.public_key())
            .unwrap()
    );
    fixture.client().remove_all_identities().unwrap();
    // Neither automatic nor explicit selection can work without the private key.
    for options in [vec!["wrap"], vec!["wrap", "-i", "source.pub"]] {
        let mut command = fixture.command();
        command.current_dir(fixture.directory.path()).args(options);
        let output = pipe(command, private.as_bytes());
        assert!(!output.status.success() && output.stdout.is_empty());
    }
    fixture.client().add_identity(&ecdsa).unwrap();
    let mut unsupported = fixture.command();
    unsupported.arg("wrap");
    assert!(!pipe(unsupported, private.as_bytes()).status.success());
}

#[test]
fn transport_uses_unlisted_keys_directly_and_requires_a_socket() {
    let fixture = Fixture::new();
    let mut command = fixture.transport("publication.pub", "", &fixture.stub());
    let output = command.output().unwrap();
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    let loaded =
        ssh_key::PublicKey::from_openssh(std::str::from_utf8(&output.stdout).unwrap().trim())
            .unwrap();
    assert_eq!(loaded.key_data(), fixture.source.public_key().key_data());
    command.env_remove("SSH_AUTH_SOCK");
    assert!(!command.output().unwrap().status.success());
    assert!(
        !fixture
            .transport("source.pub", "", &fixture.stub())
            .output()
            .unwrap()
            .status
            .success()
    );
}

#[test]
fn unlisted_identity_does_not_require_a_bundle() {
    let fixture = Fixture::new();
    fixture.wrap();
    let output = fixture
        .transport("publication.pub", "wrapped", &fixture.stub())
        .output()
        .unwrap();
    assert!(output.status.success());
    let loaded =
        ssh_key::PublicKey::from_openssh(std::str::from_utf8(&output.stdout).unwrap().trim())
            .unwrap();
    assert_eq!(loaded.key_data(), fixture.source.public_key().key_data());
    fs::remove_file(fixture.path("wrapped")).unwrap();
    assert!(
        fixture
            .transport("publication.pub", "wrapped", &fixture.stub())
            .output()
            .unwrap()
            .status
            .success()
    );
}

#[test]
fn mixed_agents_select_only_unlisted_keys_without_unwrapping() {
    let fixture = Fixture::new();
    fixture.client().add_identity(&fixture.publication).unwrap();
    let extra = PrivateKey::random(&mut OsRng, Algorithm::Ed25519).unwrap();
    fixture.client().add_identity(&extra).unwrap();
    // The missing bundle also proves no unwrap was attempted.
    let output = fixture
        .transport("source.pub", "missing", &fixture.stub())
        .output()
        .unwrap();
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    let selected = String::from_utf8(output.stdout)
        .unwrap()
        .lines()
        .map(|line| ssh_key::PublicKey::from_openssh(line).unwrap())
        .collect::<Vec<_>>();
    assert_eq!(selected.len(), 2);
    assert!(
        selected
            .iter()
            .any(|key| key.key_data() == extra.public_key().key_data())
    );
    assert!(
        selected
            .iter()
            .any(|key| key.key_data() == fixture.publication.public_key().key_data())
    );
}

#[test]
fn listed_identity_must_match_the_bundle_source() {
    let fixture = Fixture::new();
    fixture.wrap();
    fixture.client().remove_all_identities().unwrap();
    fixture.client().add_identity(&fixture.publication).unwrap();
    let output = fixture
        .transport("publication.pub", "wrapped", &fixture.stub())
        .output()
        .unwrap();
    assert!(!output.status.success());
    assert!(output.stdout.is_empty());
    assert!(
        String::from_utf8_lossy(&output.stderr).contains("not an authorized replacement identity")
    );
    // An empty forwarded agent cannot unlock a bundle even when its source is listed.
    fixture.client().remove_all_identities().unwrap();
    assert!(
        !fixture
            .transport("source.pub", "wrapped", &fixture.stub())
            .output()
            .unwrap()
            .status
            .success()
    );
}

#[test]
fn transport_derives_publication_identity_and_removes_temporary_agent() {
    let fixture = Fixture::new();
    fixture.wrap();
    // The publication public key is derived from the bundle, not a separate file.
    fs::remove_file(fixture.path("publication.pub")).unwrap();
    let output = fixture
        .transport("source.pub", "wrapped", &fixture.stub())
        .output()
        .unwrap();
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    let loaded =
        ssh_key::PublicKey::from_openssh(std::str::from_utf8(&output.stdout).unwrap().trim())
            .unwrap();
    assert_eq!(
        loaded.key_data(),
        fixture.publication.public_key().key_data()
    );
    let socket = String::from_utf8(output.stderr).unwrap();
    assert!(
        !Path::new(socket.trim()).exists(),
        "temporary socket survived transport"
    );
    let mut bytes = fs::read(fixture.path("wrapped")).unwrap();
    *bytes.last_mut().unwrap() ^= 1;
    fs::write(fixture.path("wrapped"), bytes).unwrap();
    assert!(
        !fixture
            .transport("source.pub", "wrapped", &fixture.stub())
            .output()
            .unwrap()
            .status
            .success()
    );
}

#[test]
fn bundles_reject_bad_versions_and_bound_input_before_parsing() {
    let fixture = Fixture::new();
    let bundle = fixture.wrap();
    let mut encoded = Vec::new();
    bundle.write(&mut encoded).unwrap();
    assert!(
        Bundle::read(&encoded[..encoded.len() - 1])
            .unwrap()
            .unlock(&mut fixture.client())
            .is_err()
    );
    encoded[0] ^= 1;
    assert!(Bundle::read(&encoded[..]).is_err());
    assert!(Bundle::read(std::io::repeat(0)).is_err());
    assert!(wrapping::read_bounded(std::io::repeat(0), 17).is_err());
    assert!(wrapping::read_bounded(&b"123"[..], 3).is_ok());
    let too_large = vec![0; wrapping::MAX_KEY_SIZE + 1];
    assert!(
        Bundle::wrap(
            &mut fixture.client(),
            fixture.source.public_key(),
            &too_large
        )
        .is_err()
    );
    let mut command = fixture.command();
    command
        .arg("wrap")
        .arg("-i")
        .arg(fixture.path("source.pub"));
    let output = pipe(command, &too_large);
    assert!(!output.status.success() && output.stdout.is_empty());
}

fn assert_session_cleanup(wrapped: bool, terminate_group: bool) {
    let fixture = Fixture::new();
    if wrapped {
        fixture.wrap();
    }
    let stub = fixture.path("blocking-ssh");
    fs::write(
        &stub,
        format!(
            "#!{}\nprintf '%s\\n%s\\n' \"$$\" \"$SSH_AUTH_SOCK\" > '{}'\nexec {} 20\n",
            tool("sh").display(),
            fixture.path("observed").display(),
            tool("sleep").display(),
        ),
    )
    .unwrap();
    fs::set_permissions(&stub, fs::Permissions::from_mode(0o700)).unwrap();
    let (authorized, bundle) = if wrapped {
        ("source.pub", "wrapped")
    } else {
        ("publication.pub", "")
    };
    let mut child = fixture
        .transport(authorized, bundle, &stub)
        .process_group(0)
        .spawn()
        .unwrap();
    let deadline = Instant::now() + Duration::from_secs(5);
    let (pid, socket) = loop {
        if let Ok(observed) = fs::read_to_string(fixture.path("observed")) {
            let lines: Vec<_> = observed.lines().collect();
            if lines.len() == 2 {
                break (lines[0].parse::<i32>().unwrap(), PathBuf::from(lines[1]));
            }
        }
        assert!(Instant::now() < deadline, "outbound SSH did not start");
        thread::sleep(Duration::from_millis(10));
    };
    if terminate_group {
        assert!(
            Command::new(tool("bash"))
                .args(["-c", "kill -TERM -- -\"$1\"", "test"])
                .arg(child.id().to_string())
                .status()
                .unwrap()
                .success()
        );
    } else {
        child.kill().unwrap();
    }
    child.wait().unwrap();
    // The supervisor must reap SSH, not just delete its agent socket. An already
    // authenticated connection retains its authority after the agent exits.
    while unsafe { libc::kill(pid, 0) } == 0 || (wrapped && socket.exists()) {
        assert!(
            Instant::now() < deadline,
            "publication SSH or agent survived its caller"
        );
        thread::sleep(Duration::from_millis(10));
    }
    if wrapped {
        assert!(
            !socket.parent().unwrap().exists(),
            "private runtime directory survived"
        );
    }
    // Direct sessions must leave the caller's forwarded source agent intact.
    assert!(fixture.socket.exists());
    assert!(!fixture.client().list_all_identities().unwrap().is_empty());
}

#[test]
fn killed_transport_cleans_up_ssh_and_publication_agent() {
    assert_session_cleanup(true, false);
}

#[test]
fn terminated_session_cleans_up_ssh_and_publication_agent() {
    assert_session_cleanup(true, true);
}

#[test]
fn killed_direct_transport_stops_ssh_and_preserves_source_agent() {
    assert_session_cleanup(false, false);
}

#[test]
fn supervision_preserves_git_protocol_stdin_and_stdout() {
    let fixture = Fixture::new();
    fixture.wrap();
    let stub = fixture.path("echo-ssh");
    fs::write(
        &stub,
        format!(
            "#!{}\nexec {}\n",
            tool("sh").display(),
            tool("cat").display()
        ),
    )
    .unwrap();
    fs::set_permissions(&stub, fs::Permissions::from_mode(0o700)).unwrap();
    let message = b"0032git protocol input\0with binary data\n0000";
    let output = pipe(fixture.transport("source.pub", "wrapped", &stub), message);
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    assert_eq!(output.stdout, message);
}

#[test]
#[ignore = "requires explicitly supplied pinned Go plugin; never a runtime dependency"]
fn interoperates_with_reference_plugin() {
    let fixture = Fixture::new();
    let plugin = std::env::var_os("GIT_FORWARD_TEST_PLUGIN")
        .expect("supply the pinned reference plugin binary");
    let bundle = fixture.wrap();
    fs::write(fixture.path("identity"), bundle.metadata.encode().unwrap()).unwrap();
    fs::write(fixture.path("inner.age"), &bundle.ciphertext).unwrap();
    let metadata = bundle.metadata;
    let rust_recipient = metadata
        .derive(&mut fixture.client(), fixture.source.public_key())
        .unwrap()
        .to_public();
    let output = Command::new(&plugin)
        .arg("recipient")
        .arg("-i")
        .arg(fixture.path("identity"))
        .env("SSH_AUTH_SOCK", &fixture.socket)
        .output()
        .unwrap();
    assert!(output.status.success());
    assert_eq!(
        std::str::from_utf8(&output.stdout).unwrap().trim(),
        rust_recipient.to_string()
    );
    let plugin_directory = Path::new(&plugin).parent().unwrap();
    let mut paths = vec![plugin_directory.to_path_buf()];
    paths.extend(std::env::split_paths(&std::env::var_os("PATH").unwrap()));
    let output = Command::new(tool("age"))
        .args(["-d", "-i"])
        .arg(fixture.path("identity"))
        .arg(fixture.path("inner.age"))
        .env("PATH", std::env::join_paths(paths).unwrap())
        .env("SSH_AUTH_SOCK", &fixture.socket)
        .output()
        .unwrap();
    assert!(output.status.success());
    assert!(
        PrivateKey::from_openssh(&output.stdout)
            .unwrap()
            .public_key()
            == fixture.publication.public_key()
    );
    let output = Command::new(&plugin)
        .arg("keygen")
        .arg("-o")
        .arg(fixture.path("go-identity"))
        .env("SSH_AUTH_SOCK", &fixture.socket)
        .output()
        .unwrap();
    assert!(output.status.success());
    let metadata =
        Metadata::parse(&fs::read_to_string(fixture.path("go-identity")).unwrap()).unwrap();
    let output = Command::new(&plugin)
        .arg("recipient")
        .arg("-i")
        .arg(fixture.path("go-identity"))
        .env("SSH_AUTH_SOCK", &fixture.socket)
        .output()
        .unwrap();
    assert!(output.status.success());
    assert_eq!(
        std::str::from_utf8(&output.stdout).unwrap().trim(),
        metadata
            .derive(&mut fixture.client(), fixture.source.public_key())
            .unwrap()
            .to_public()
            .to_string()
    );
    let mut encrypt = Command::new(tool("age"));
    encrypt
        .arg("-r")
        .arg(std::str::from_utf8(&output.stdout).unwrap().trim());
    let private = fixture.publication.to_openssh(LineEnding::LF).unwrap();
    let ciphertext = pipe(encrypt, private.as_bytes());
    assert!(ciphertext.status.success());
    let plaintext = wrapping::decrypt(
        &metadata,
        &mut fixture.client(),
        fixture.source.public_key(),
        &ciphertext.stdout,
    )
    .unwrap();
    assert!(plaintext.as_slice() == private.as_bytes());
}
