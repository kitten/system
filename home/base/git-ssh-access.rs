use std::env;
use std::error::Error;
use std::fs;
use std::io;
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
}

impl Access {
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
        let repository = self.home.join(name).canonicalize()?;
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

fn run() -> Result<()> {
    let arguments: Vec<_> = env::args_os().skip(1).collect();
    if arguments.len() != 5 || !matches!(arguments[4].to_str(), Some("true" | "false")) {
        return Err(
            "expected home, Git root, Git executable, hooks directory, and push policy".into(),
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
    };
    let repository = access.repository(name)?;
    Err(access.git().arg(operation).arg(repository).exec().into())
}

fn main() {
    if let Err(error) = run() {
        eprintln!("Git SSH access denied: {error}");
        std::process::exit(1);
    }
}
