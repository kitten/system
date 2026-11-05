use git_ssh_access::{Result, forwarding, wrapping};
use std::env;
use std::fs;
use std::io::{self, BufRead};
use std::os::unix::process::CommandExt;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

// Resolve missing metadata paths too, following dangling symlinks so that a
// future ref or object directory cannot silently extend the exposed root.
fn resolve(path: &Path, depth: usize) -> io::Result<PathBuf> {
    if depth > 64 {
        return Err(io::Error::other("too many path indirections"));
    }
    match path.canonicalize() {
        Ok(path) => Ok(path),
        Err(error) if error.kind() == io::ErrorKind::NotFound => {
            let parent = path.parent().ok_or(error)?;
            if let Ok(target) = fs::read_link(path) {
                return resolve(&parent.join(target), depth + 1);
            }
            let name = path
                .file_name()
                .ok_or_else(|| io::Error::other("invalid path"))?;
            Ok(resolve(parent, depth + 1)?.join(name))
        }
        Err(error) => Err(error),
    }
}

struct Access {
    home: PathBuf,
    root: PathBuf,
    git: PathBuf,
    hooks: PathBuf,
    ssh: PathBuf,
    prefixes: Vec<String>,
}

impl Access {
    fn allowed(&self, reference: &str) -> bool {
        allowed_ref(reference, &self.prefixes)
    }

    fn origin(&self, repository: &Path) -> Result<String> {
        let output = self
            .git()
            .arg("-C")
            .arg(repository)
            .args(["remote", "get-url", "--push", "--all", "origin"])
            .output()?;
        if !output.status.success() {
            return Err("receiving repository has no usable origin".into());
        }
        let value = String::from_utf8(output.stdout)?;
        let urls: Vec<_> = value.lines().collect();
        if urls.len() != 1 {
            return Err("origin must have exactly one push URL".into());
        }
        let name = urls[0]
            .strip_prefix("git@github.com:")
            .or_else(|| urls[0].strip_prefix("ssh://git@github.com/"))
            .ok_or("origin must be a GitHub SSH URL")?;
        let name = name.strip_suffix(".git").unwrap_or(name);
        let parts: Vec<_> = name.split('/').collect();
        if parts.len() != 2
            || parts.iter().any(|part| {
                part.is_empty()
                    || matches!(*part, "." | "..")
                    || !part
                        .bytes()
                        .all(|byte| byte.is_ascii_alphanumeric() || b"._-".contains(&byte))
            })
        {
            return Err("invalid GitHub origin".into());
        }
        Ok(format!("git@github.com:{name}.git"))
    }

    fn outbound(&self, repository: &Path) -> Command {
        let mut command = self.git();
        command
            .env("HOME", &self.home)
            .env(
                "SSH_AUTH_SOCK",
                env::var_os("SSH_AUTH_SOCK").unwrap_or_default(),
            )
            .arg("-c")
            .arg(format!("core.sshCommand={}", self.ssh.display()))
            .arg("-c")
            .arg("push.gpgSign=false")
            .arg("-c")
            .arg("ssh.variant=ssh")
            .arg("-c")
            .arg("push.followTags=false")
            .arg("-c")
            .arg("push.recurseSubmodules=no")
            .arg("-c")
            .arg("advice.pushUpdateRejected=false")
            .arg("-C")
            .arg(repository);
        command
    }

    fn remote_tip(&self, repository: &Path, url: &str, reference: &str) -> Result<String> {
        let output = self
            .outbound(repository)
            .args(["ls-remote", "--refs", url, reference])
            .stderr(Stdio::inherit())
            .output()?;
        if !output.status.success() {
            return Err(format!(
                "cannot read {reference} at origin {url}; check the destination account's SSH access to origin. Local receipt has not started"
            ).into());
        }
        let value = String::from_utf8(output.stdout)?;
        if value.is_empty() {
            return Ok(String::new());
        }
        let (sha, name) = value
            .trim_end()
            .split_once('\t')
            .ok_or("invalid origin response")?;
        if !valid_sha(sha) || name != reference {
            return Err("unexpected origin response".into());
        }
        Ok(sha.to_owned())
    }

    fn receive_and_send(&self, repository: &Path, request: &str) -> Result<()> {
        let fields: Vec<_> = request.split(':').collect();
        let [mode, reference, sha] = fields.as_slice() else {
            return Err("expected forwarding mode, branch ref, and commit".into());
        };
        if !matches!(*mode, "ff" | "lease") || !valid_sha(sha) {
            return Err("invalid forwarding request".into());
        }
        if !self.allowed(reference) {
            return Err(prefix_error(reference, &self.prefixes).into());
        }
        let url = self.origin(repository)?;
        let previous = self.metadata(repository, &["--verify", reference]).ok();
        // Observe origin before receiving, so a concurrent update cannot be
        // silently overwritten by the onward lease-protected push.
        // Authenticate before receipt even for fast-forward sends. Never silently
        // fall back to a receiver-local identity when forwarding is unavailable.
        let tip = self.remote_tip(repository, &url, reference)?;
        let expected = (*mode == "lease").then_some(tip);
        if !self
            .git()
            .arg("receive-pack")
            .arg(repository)
            .status()?
            .success()
        {
            return Err(format!("local receipt of {reference} into {} failed; origin {url} was not updated. Resolve the receive error above before retrying", repository.display()).into());
        }
        let symbolic = self
            .git()
            .arg("-C")
            .arg(repository)
            .args(["symbolic-ref", "--quiet", reference])
            .output()?;
        let current = self.metadata(repository, &["--verify", reference]).ok();
        if symbolic.status.code() != Some(1) {
            return Err(format!(
                "cannot forward {reference} in {} as a direct branch; it is symbolic or could not be inspected. Select a direct branch or ask the destination account owner to repair the ref. Origin {url} was not updated", repository.display()
            ).into());
        }
        if current.as_deref() != Some(*sha) {
            let hint = if current != previous {
                "The destination branch changed during receipt; inspect its new tip before retrying."
            } else if *mode == "lease" {
                "Review Git's receive rejection and the destination's current tip before retrying; do not blindly refresh the lease."
            } else {
                "Resolve Git's receive rejection. If it reports non-fast-forward, integrate the destination changes, or retry git send --force-with-lease only if intentionally replacing rebased history."
            };
            return Err(format!(
                "{reference} at {} is not the requested commit {sha} (current tip: {}). Origin {url} was not updated.\n{hint}",
                repository.display(), current.as_deref().unwrap_or("missing or unreadable")
            ).into());
        }
        let mut command = self.outbound(repository);
        command.args(["push", "--porcelain"]);
        if let Some(expected) = expected {
            command.arg(format!("--force-with-lease={reference}:{expected}"));
        }
        // Capture porcelain for classification and print it on stderr, leaving
        // the receive protocol on stdout undisturbed. Keep native diagnostics.
        command.arg(&url).arg(format!("{sha}:{reference}"));
        let output = command.stderr(Stdio::inherit()).output()?;
        let report = String::from_utf8_lossy(&output.stdout);
        if !output.status.success() {
            let hint = push_rejection_hint(&report);
            let reason = report
                .lines()
                .find_map(|line| {
                    line.strip_prefix("!\t")
                        .and_then(|line| line.split_once('\t').map(|(_, reason)| reason))
                })
                .unwrap_or("see Git's diagnostic above");
            return Err(format!(
                "origin publication failed for {reference} at {url}: {reason}.\nCommit {sha} was received into {}.\nInspect origin with: git fetch {url} {reference}\n{hint}", repository.display()
            ).into());
        }
        eprintln!("Forwarded {reference} to {url}");
        Ok(())
    }

    fn within_root(&self, path: &Path) -> Result<PathBuf> {
        let path = resolve(path, 0)?;
        if !path.starts_with(&self.root) {
            return Err("repository or metadata escapes the Git directory".into());
        }
        Ok(path)
    }

    fn git(&self) -> Command {
        let mut command = Command::new(&self.git);
        // Do not inherit credentials, client GIT_* variables, or personal Git
        // settings. Incomplete partial clones must be hydrated by their owner.
        command
            .env_clear()
            .current_dir(&self.home)
            .env("PATH", self.git.parent().unwrap())
            .env("LC_ALL", "C")
            .env("GIT_CONFIG_NOSYSTEM", "1")
            .env("GIT_CONFIG_GLOBAL", "/dev/null")
            .env("GIT_NO_LAZY_FETCH", "1")
            .env("GIT_TERMINAL_PROMPT", "0");
        if let Ok(protocol) = env::var("GIT_PROTOCOL")
            && matches!(protocol.as_str(), "version=0" | "version=1" | "version=2")
        {
            command.env("GIT_PROTOCOL", protocol);
        }
        for setting in [
            format!("core.hooksPath={}", self.hooks.display()),
            "core.fsmonitor=false".into(),
            "gc.auto=0".into(),
            "maintenance.auto=false".into(),
            "receive.autogc=false".into(),
            "receive.denyCurrentBranch=refuse".into(),
            "receive.denyDeleteCurrent=true".into(),
            "transfer.fsckObjects=true".into(),
        ] {
            command.arg("-c").arg(setting);
        }
        command
    }

    fn metadata(&self, repository: &Path, arguments: &[&str]) -> Result<String> {
        let output = self
            .git()
            .arg("-C")
            .arg(repository)
            .arg("rev-parse")
            .args(arguments)
            .output()?;
        if !output.status.success() {
            return Err("not a usable Git repository".into());
        }
        let value = String::from_utf8(output.stdout)?;
        Ok(value.strip_suffix('\n').unwrap_or(&value).to_owned())
    }

    fn repository(&self, name: &str) -> Result<PathBuf> {
        let path = self.home.join(name);
        let repository = match path.canonicalize() {
            Ok(repository) => repository,
            Err(error)
                if error.kind() == io::ErrorKind::NotFound
                    && path.file_name().is_some_and(|part| part != ".git")
                    && name.ends_with(".git") =>
            {
                self.home
                    .join(name.strip_suffix(".git").unwrap())
                    .canonicalize()?
            }
            Err(error) => return Err(error.into()),
        };
        self.within_root(&repository)?;
        if repository
            .strip_prefix(&self.root)?
            .components()
            .any(|component| component.as_os_str().as_encoded_bytes().starts_with(b"."))
        {
            return Err("repositories in dot directories are not accessible".into());
        }
        let gitdir = self.within_root(Path::new(
            &self.metadata(&repository, &["--absolute-git-dir"])?,
        ))?;
        let common = self.within_root(Path::new(
            &self.metadata(&repository, &["--path-format=absolute", "--git-common-dir"])?,
        ))?;
        let toplevel = if self.metadata(&repository, &["--is-bare-repository"])? == "true" {
            gitdir.clone()
        } else {
            PathBuf::from(self.metadata(&repository, &["--show-toplevel"])?).canonicalize()?
        };
        if toplevel != repository {
            return Err("expected a repository root".into());
        }
        for directory in [&gitdir, &common] {
            for entry in [
                "HEAD",
                "config",
                "config.worktree",
                "objects",
                "refs",
                "logs",
                "packed-refs",
                "reftable",
                "shallow",
                "hooks",
                "info",
            ] {
                self.within_root(&directory.join(entry))?;
            }
        }
        for entry in ["objects/info", "objects/pack", "objects/info/alternates"] {
            self.within_root(&common.join(entry))?;
        }
        match fs::metadata(common.join("objects/info/alternates")) {
            Ok(metadata) if metadata.len() > 0 => {
                return Err("object alternates are not supported".into());
            }
            Err(error) if error.kind() != io::ErrorKind::NotFound => return Err(error.into()),
            _ => {}
        }
        Ok(repository)
    }
}

fn push_rejection_hint(report: &str) -> &'static str {
    let rejected: Vec<_> = report
        .lines()
        .filter(|line| line.starts_with("!\t"))
        .collect();
    if rejected
        .iter()
        .any(|line| line.ends_with("\t[rejected] (stale info)"))
    {
        "Origin changed during this send. Fetch and review its new tip before retrying; do not blindly refresh the lease."
    } else if rejected.iter().any(|line| {
        line.ends_with("\t[rejected] (non-fast-forward)")
            || line.ends_with("\t[rejected] (fetch first)")
    }) {
        "Integrate origin's changes. If intentionally replacing rebased history, retry git send --force-with-lease with the same branch and SSH destination."
    } else {
        "Resolve the origin authentication, connectivity, or server-policy error above, then retry git send with the same branch and SSH destination."
    }
}

fn valid_sha(value: &str) -> bool {
    matches!(value.len(), 40 | 64) && value.bytes().all(|byte| byte.is_ascii_hexdigit())
}

fn allowed_ref(reference: &str, prefixes: &[String]) -> bool {
    let Some(branch) = reference.strip_prefix("refs/heads/") else {
        return false;
    };
    !branch.is_empty()
        && !branch.contains("..")
        && !branch.contains("@{")
        && !branch.ends_with('/')
        && !branch.ends_with('.')
        && branch
            .split('/')
            .all(|part| !part.is_empty() && !part.starts_with('.') && !part.ends_with(".lock"))
        && branch
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || b"@._/-".contains(&byte))
        && prefixes
            .iter()
            .any(|prefix| branch.starts_with(prefix) && branch.len() > prefix.len())
}

fn prefix_error(reference: &str, prefixes: &[String]) -> String {
    let allowed = if prefixes.is_empty() {
        "none (branch updates are disabled)".to_owned()
    } else {
        prefixes.join(", ")
    };
    format!("ref {reference} is not permitted; allowed branch prefixes: {allowed}")
}

fn check(git: &Path, prefixes: &[String]) -> Result<()> {
    for line in io::stdin().lock().lines() {
        let line = line?;
        let fields: Vec<_> = line.split_whitespace().collect();
        if fields.len() != 3
            || !valid_sha(fields[0])
            || !valid_sha(fields[1])
            || fields[1].bytes().all(|byte| byte == b'0')
        {
            return Err(
                "only non-deletion updates to permitted branch prefixes are allowed".into(),
            );
        }
        if !allowed_ref(fields[2], prefixes) {
            return Err(prefix_error(fields[2], prefixes).into());
        }
        // receive-pack dereferences symbolic refs: an allowed name could otherwise
        // update a forbidden branch. Only direct refs may be received.
        let symbolic = Command::new(git)
            .args(["symbolic-ref", "--quiet", fields[2]])
            .output()?;
        if symbolic.status.code() != Some(1) {
            return Err("updates to symbolic branch refs are forbidden".into());
        }
    }
    Ok(())
}

fn run() -> Result<()> {
    let arguments: Vec<_> = env::args_os().skip(1).collect();
    if arguments
        .first()
        .is_some_and(|value| value == "--help" || value == "-h" || value == "help")
    {
        println!(
            "Usage:\n  git-ssh-access wrap [-i public-key-file] < private-key > wrapped-key\n  git-ssh-access unwrap < wrapped-key\n\nThe source identity must be available through SSH_AUTH_SOCK.\nWithout -i, wrap requires exactly one supported Ed25519 identity in the agent.\nGit transport and forced-command modes are configured by the Nix module."
        );
        return Ok(());
    }
    if arguments
        .first()
        .is_some_and(|value| value == "wrap" || value == "unwrap")
    {
        return wrapping::run(&arguments);
    }
    if arguments
        .first()
        .is_some_and(|value| value == "transport" || value == "transport-supervisor")
    {
        return forwarding::run(&arguments);
    }
    if arguments.first().is_some_and(|value| value == "check") {
        let git = arguments.get(1).ok_or("expected Git executable")?;
        let prefixes = arguments[2..]
            .iter()
            .map(|value| value.to_str().map(str::to_owned).ok_or("invalid prefix"))
            .collect::<std::result::Result<Vec<_>, _>>()?;
        return check(Path::new(git), &prefixes);
    }
    if arguments.len() < 6 || !matches!(arguments[4].to_str(), Some("true" | "false")) {
        return Err(
            "expected home, Git root, Git executable, hooks directory, push policy, SSH executable, and prefixes".into(),
        );
    }
    let request = env::var("SSH_ORIGINAL_COMMAND")?;
    let (operation, argument) = request.split_once(' ').ok_or("expected a Git command")?;
    let operation = match operation {
        "git-upload-pack" => "upload-pack",
        "git-receive-pack" if arguments[4] == "true" => "receive-pack",
        _ => return Err("only permitted Git fetch/push commands are accepted".into()),
    };
    // Git's SSH transport quotes the path. Parse only ordinary repository names;
    // never interpret the supplied command as shell code.
    let (argument, forwarding) = if operation == "receive-pack" && argument.starts_with("--send=") {
        let (option, path) = argument
            .split_once(' ')
            .ok_or("expected forwarding option and repository")?;
        (path, Some(option.strip_prefix("--send=").unwrap()))
    } else {
        (argument, None)
    };
    let name = argument
        .strip_prefix('\'')
        .and_then(|value| value.strip_suffix('\''))
        .ok_or("expected a single-quoted repository path")?;
    if !name
        .bytes()
        .all(|byte| byte.is_ascii_alphanumeric() || b"._-/".contains(&byte))
        || name
            .strip_prefix('/')
            .unwrap_or(name)
            .split('/')
            .any(|part| matches!(part, "" | "." | ".."))
    {
        return Err("expected a home-relative or absolute repository path".into());
    }
    let access = Access {
        home: PathBuf::from(&arguments[0]).canonicalize()?,
        root: PathBuf::from(&arguments[1]).canonicalize()?,
        git: PathBuf::from(&arguments[2]),
        hooks: PathBuf::from(&arguments[3]),
        ssh: PathBuf::from(&arguments[5]),
        prefixes: arguments[6..]
            .iter()
            .map(|value| value.to_str().map(str::to_owned).ok_or("invalid prefix"))
            .collect::<std::result::Result<Vec<_>, _>>()?,
    };
    let repository = access.repository(name)?;
    if let Some(request) = forwarding {
        return access.receive_and_send(&repository, request);
    }
    Err(access.git().arg(operation).arg(repository).exec().into())
}

fn main() {
    if let Err(error) = run() {
        eprintln!("Git SSH access denied: {error}");
        std::process::exit(1);
    }
}
