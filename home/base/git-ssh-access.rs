use std::env;
use std::error::Error;
use std::fs;
use std::io::{self, BufRead};
use std::os::unix::process::CommandExt;
use std::path::{Path, PathBuf};
use std::process::Command;

type Result<T> = std::result::Result<T, Box<dyn Error>>;

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
            .arg("-c")
            .arg(format!(
                "core.sshCommand={} -oBatchMode=yes -oForwardAgent=no",
                self.ssh.display()
            ))
            .arg("-c")
            .arg("push.gpgSign=false")
            .arg("-c")
            .arg("push.followTags=false")
            .arg("-c")
            .arg("push.recurseSubmodules=no")
            .arg("-C")
            .arg(repository);
        command
    }

    fn remote_tip(&self, repository: &Path, url: &str, reference: &str) -> Result<String> {
        let output = self
            .outbound(repository)
            .args(["ls-remote", "--refs", url, reference])
            .output()?;
        if !output.status.success() {
            return Err("could not read origin branch tip".into());
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
        if !matches!(*mode, "ff" | "lease") || !self.allowed(reference) || !valid_sha(sha) {
            return Err("invalid forwarding request".into());
        }
        let url = self.origin(repository)?;
        // Observe origin before receiving, so a concurrent update cannot be
        // silently overwritten by the onward lease-protected push.
        let expected = if *mode == "lease" {
            Some(self.remote_tip(repository, &url, reference)?)
        } else {
            None
        };
        if !self
            .git()
            .arg("receive-pack")
            .arg(repository)
            .status()?
            .success()
        {
            return Err("local Git receive failed; origin was not updated".into());
        }
        let symbolic = self
            .git()
            .arg("-C")
            .arg(repository)
            .args(["symbolic-ref", "--quiet", reference])
            .output()?;
        if symbolic.status.code() != Some(1)
            || self.metadata(repository, &["--verify", reference])? != *sha
        {
            return Err("local branch changed or requested commit was not received".into());
        }
        let mut command = self.outbound(repository);
        command.arg("push");
        if let Some(expected) = expected {
            command.arg(format!("--force-with-lease={reference}:{expected}"));
        }
        // Git's normal push output goes to stderr, leaving the receive protocol
        // on stdout undisturbed. Use the requested SHA even if the ref moves.
        command.arg(&url).arg(format!("{sha}:{reference}"));
        if !command.status()?.success() {
            return Err(
                "branch received locally, but publication to origin failed; retry git send".into(),
            );
        }
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
        if let Ok(protocol) = env::var("GIT_PROTOCOL") {
            if matches!(protocol.as_str(), "version=0" | "version=1" | "version=2") {
                command.env("GIT_PROTOCOL", protocol);
            }
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

fn check(git: &Path, prefixes: &[String]) -> Result<()> {
    for line in io::stdin().lock().lines() {
        let line = line?;
        let fields: Vec<_> = line.split_whitespace().collect();
        if fields.len() != 3
            || !valid_sha(fields[0])
            || !valid_sha(fields[1])
            || fields[1].bytes().all(|byte| byte == b'0')
            || !allowed_ref(fields[2], prefixes)
        {
            return Err(
                "only non-deletion updates to permitted branch prefixes are allowed".into(),
            );
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
