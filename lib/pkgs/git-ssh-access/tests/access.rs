use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};

fn tool(name: &str) -> PathBuf {
    std::env::split_paths(&std::env::var_os("PATH").unwrap())
        .map(|path| path.join(name))
        .find(|path| path.is_file())
        .unwrap()
}

fn git(directory: &Path, arguments: &[&str]) -> Output {
    Command::new(tool("git"))
        .arg("-C")
        .arg(directory)
        .args([
            "-c",
            "commit.gpgSign=false",
            "-c",
            "user.name=Fixture",
            "-c",
            "user.email=fixture@example.invalid",
        ])
        .args(arguments)
        .env("GIT_CONFIG_GLOBAL", "/dev/null")
        .env("GIT_CONFIG_NOSYSTEM", "1")
        .output()
        .unwrap()
}

fn success(output: Output) -> String {
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    String::from_utf8(output.stdout).unwrap().trim().to_owned()
}

fn script(path: &Path, contents: &str) {
    fs::write(path, format!("#!{}\n{contents}\n", tool("sh").display())).unwrap();
    fs::set_permissions(path, fs::Permissions::from_mode(0o700)).unwrap();
}

#[test]
fn restricted_receipt_and_publication_preserve_git_policy() {
    let directory = tempfile::Builder::new()
        .prefix("git-access-")
        .tempdir_in("/tmp")
        .unwrap();
    let home = directory.path();
    let root = home.join("git");
    let destination = root.join("org/repo");
    let origin = home.join("origin");
    let source = home.join("source");
    let hooks = home.join("hooks");
    fs::create_dir_all(&destination).unwrap();
    fs::create_dir_all(&origin).unwrap();
    fs::create_dir_all(&source).unwrap();
    fs::create_dir(&hooks).unwrap();
    success(git(&destination, &["init", "--bare"]));
    success(git(&origin, &["init", "--bare"]));
    success(git(&source, &["init"]));
    success(git(
        &destination,
        &["remote", "add", "origin", "git@github.com:org/repo.git"],
    ));
    let helper = env!("CARGO_BIN_EXE_git-ssh-access");
    script(
        &hooks.join("pre-receive"),
        &format!(
            "exec '{helper}' check '{}' '@kitten/'",
            tool("git").display()
        ),
    );
    let outbound = home.join("outbound");
    script(
        &outbound,
        &format!(
            "[ \"$SSH_AUTH_SOCK\" = forwarded-fixture ] || exit 7\ncase \"$*\" in *git-upload-pack*) exec '{}' upload-pack '{}' ;; *git-receive-pack*) exec '{}' receive-pack '{}' ;; *) exit 8 ;; esac",
            tool("git").display(),
            origin.display(),
            tool("git").display(),
            origin.display()
        ),
    );
    let inbound = home.join("inbound");
    // Model shell startup replacing SSH_AUTH_SOCK after capturing sshd's value.
    script(
        &inbound,
        &format!(
            "shift\nexport GIT_SSH_ACCESS_AUTH_SOCK=\"${{SSH_AUTH_SOCK-}}\"\nexport SSH_AUTH_SOCK=unrelated-local-agent\nexport SSH_ORIGINAL_COMMAND=\"$*\"\nexec '{helper}' '{}' '{}' '{}' '{}' true '{}' '@kitten/'",
            home.display(),
            root.display(),
            tool("git").display(),
            hooks.display(),
            outbound.display()
        ),
    );
    success(git(
        &source,
        &["symbolic-ref", "HEAD", "refs/heads/@kitten/test"],
    ));
    fs::write(source.join("file"), "first").unwrap();
    success(git(&source, &["add", "file"]));
    success(git(&source, &["commit", "-m", "first"]));
    let first = success(git(&source, &["rev-parse", "HEAD"]));
    let push = |mode: Option<&str>, reference: &str, socket: bool| {
        let mut command = Command::new(tool("git"));
        command
            .arg("-C")
            .arg(&source)
            .args(["-c", "push.gpgSign=false", "-c", "ssh.variant=ssh"])
            .arg("push");
        if let Some(mode) = mode {
            let sha = success(git(&source, &["rev-parse", "HEAD"]));
            command.arg(format!(
                "--receive-pack=git-receive-pack --send={mode}:{reference}:{sha}"
            ));
        }
        command
            .arg("operator:git/org/repo")
            .arg(format!("HEAD:{reference}"))
            .env("GIT_SSH_COMMAND", &inbound)
            .env("GIT_CONFIG_GLOBAL", "/dev/null")
            .env("GIT_CONFIG_NOSYSTEM", "1");
        if socket {
            command.env("SSH_AUTH_SOCK", "forwarded-fixture");
        } else {
            command.env_remove("SSH_AUTH_SOCK");
        }
        command.output().unwrap()
    };
    let reference = "refs/heads/@kitten/test";
    success(push(None, reference, false));
    assert_eq!(success(git(&destination, &["rev-parse", reference])), first);
    assert!(
        !git(&origin, &["rev-parse", "--verify", reference])
            .status
            .success()
    );
    success(push(Some("ff"), reference, true));
    assert_eq!(success(git(&origin, &["rev-parse", reference])), first);
    fs::write(source.join("file"), "second").unwrap();
    success(git(&source, &["commit", "-am", "second"]));
    let second = success(git(&source, &["rev-parse", "HEAD"]));
    let missing_forwarding = push(Some("ff"), reference, false);
    assert!(!missing_forwarding.status.success());
    assert!(
        String::from_utf8_lossy(&missing_forwarding.stderr)
            .contains("requires SSH agent forwarding captured by the receiving shell")
    );
    assert_eq!(
        success(git(&destination, &["rev-parse", reference])),
        first,
        "authentication must precede local receipt"
    );
    success(push(Some("lease"), reference, true));
    assert_eq!(success(git(&origin, &["rev-parse", reference])), second);
    assert!(!push(Some("ff"), "refs/heads/main", true).status.success());
    assert!(!push(Some("ff"), "refs/tags/release", true).status.success());
    assert!(
        !git(&destination, &["show-ref", "--verify", "refs/heads/main"])
            .status
            .success()
    );
}
