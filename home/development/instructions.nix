{ lib, config, pkgs, user, ... }:

with lib;
let
  cfg = config.modules.development.instructions;
  isAgent = config.modules.agent.enable or false;
  sharedInstructions = ''
    - Shared repos live at `~/git/<org>/<repo>`; clone with `git get <org>/<repo>`
      - Use SSH remotes
      - For forks, `origin` is the fork and `upstream` the canonical repo. The local default branch tracks `upstream/<default>`
      - After adding any remote, run `git normalize-remotes`
      - Fetch third-party PRs with `git pr <number>` (detached HEAD)
      - Send your branch to other accounts or machines with `git send [user@host|host]`
      - Receive a branch with `git receive [user@host|host]`; updates are fast-forward only. Add `--branch <name>` to select another branch
      - Check branch/status; preserve unrelated changes in shared checkouts
    - Tools come from Nix; use `nix run nixpkgs#tool -- args` for additional tools
      - Don't directly alter live configs or tooling outside ~/git unless requested
      - Use configured devshells: `nix develop -c <command>` or `direnv exec . <command>`
      - Don't assume Homebrew, nvm, or Cargo paths
      - Check installed/pinned versions; discover supported commands and flags via CLI help
      - Shells use zsh. Quote search globs
    - Follow repo instructions, package managers, scripts, and formatters; read each checkout's agent instructions before editing
      - Verify checkout dependencies before diagnosing test failures
      - Cross-repo tests: verify resolved packages and built artifacts, including native binaries; links affect resolution
      - Prefer headless/offscreen testing
      - When benchmarking, use representative workloads and the intended baseline
      - Keep changes and explanations focused. Avoid redundant docs/comments and committed temporary artifacts
  '';
  agentInstructions = ''
    Agent account:
    - Running as `${config.home.username}`; operator: `${user}`
    - Headless; don't depend on a desktop login
    - Use `git send ${user}@localhost` to send a branch to the operator's matching repo; this destination is the default. Add `--local-only` to prevent the destination from forwarding the branch to its `origin`
  '';
  send = pkgs.writeShellApplication {
    name = "git-send";
    runtimeInputs = [ pkgs.git pkgs.openssh ];
    text = ''
      local_only=${boolToString (!isAgent)}
      mode=ff
      branch=""
      while [[ $# -gt 0 ]]; do
        case "$1" in
        --local-only) local_only=true ;;
        --force-with-lease) mode=lease ;;
        --branch)
          if [[ $# -lt 2 || -z "$2" ]]; then
            echo '--branch requires a branch name' >&2
            exit 2
          fi
          branch=$2
          shift
          ;;
        --help | -h)
          echo 'Usage: git send ${optionalString isAgent "[--local-only] "}[--force-with-lease] [--branch name] [user@host|host]'
          exit 0
          ;;
        *) break ;;
        esac
        shift
      done
      if [[ $# -gt 1 || ''${1-} == -* ]]; then
        echo 'Usage: git send ${optionalString isAgent "[--local-only] "}[--force-with-lease] [--branch name] [user@host|host]' >&2
        exit 2
      fi

      host=''${1-localhost}
      if [[ "$host" != *@* ]]; then host=${escapeShellArg user}@"$host"; fi
      if [[ ! "$host" =~ ^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+$ ]]; then
        echo 'Expected a hostname or user@hostname' >&2
        exit 2
      fi
      root=$(cd ${escapeShellArg config.modules.git.directory} && pwd -P)
      common=$(git rev-parse --path-format=absolute --git-common-dir)
      case "$common" in
        "$root"/*/.git)
          path="git/''${common#"$root"/}"
          path=''${path%/.git}
          ;;
        *) echo "Repository must live beneath $root" >&2; exit 2 ;;
      esac
      ref="refs/heads/''${branch:-$(git symbolic-ref --quiet --short HEAD)}"
      if [[ ! "$ref" =~ ^refs/heads/[a-zA-Z0-9@._/-]+$ ]]; then
        echo "Unsupported branch: $ref" >&2
        exit 2
      fi
      sha=$(git rev-parse --verify "$ref^{commit}")

      lease=()
      if [[ "$mode" == lease ]]; then
        tip=$(git ls-remote --refs "$host:$path" "$ref")
        lease=("--force-with-lease=$ref:''${tip%%$'\t'*}")
      fi

      receive=()
      if ! $local_only; then
        receive=("--receive-pack=git-receive-pack --send=$mode:$ref:$sha")
      fi
      ssh_command=''${GIT_SSH_COMMAND:-$(git config --get core.sshCommand || true)}
      ssh_command=''${ssh_command:-''${GIT_SSH:-${pkgs.openssh}/bin/ssh}}
      # Forward the selected authentication agent and bypass existing masters.
      export GIT_SSH_COMMAND="$ssh_command -A -S none"
      export GIT_SSH_VARIANT=ssh
      # shellcheck disable=SC2016
      exec ${optionalString (isAgent && config.modules.agent.sshKey != null) ''
        ssh-agent -t 1200 ${pkgs.runtimeShell} -c '
          export SSH_ASKPASS_REQUIRE=never
          ssh-add "$1" </dev/null || exit
          shift
          exec "$@"
        ' git-send ${escapeShellArg config.modules.agent.sshKey} ''}git \
        -c push.followTags=false -c push.recurseSubmodules=no push \
        "''${receive[@]}" "''${lease[@]}" "$host:$path" "$sha:$ref"
    '';
  };
  receive = pkgs.writeShellApplication {
    name = "git-receive";
    runtimeInputs = [ pkgs.git pkgs.openssh ];
    text = ''
      branch=""
      while [[ $# -gt 0 ]]; do
        case "$1" in
        --branch)
          if [[ $# -lt 2 || -z "$2" ]]; then
            echo '--branch requires a branch name' >&2
            exit 2
          fi
          branch=$2
          shift
          ;;
        --help | -h)
          echo 'Usage: git receive [--branch name] [user@host|host]'
          exit 0
          ;;
        *) break ;;
        esac
        shift
      done
      if [[ $# -gt 1 || ''${1-} == -* ]]; then
        echo 'Usage: git receive [--branch name] [user@host|host]' >&2
        exit 2
      fi

      host=''${1-localhost}
      if [[ "$host" != *@* ]]; then host=${escapeShellArg user}@"$host"; fi
      if [[ ! "$host" =~ ^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+$ ]]; then
        echo 'Expected a hostname or user@hostname' >&2
        exit 2
      fi
      root=$(cd ${escapeShellArg config.modules.git.directory} && pwd -P)
      common=$(git rev-parse --path-format=absolute --git-common-dir)
      case "$common" in
        "$root"/*/.git)
          path="git/''${common#"$root"/}"
          path=''${path%/.git}
          ;;
        *) echo "Repository must live beneath $root" >&2; exit 2 ;;
      esac
      current=$(git symbolic-ref --quiet HEAD || true)
      if [[ -z "$branch" ]]; then
        if [[ -z "$current" ]]; then
          echo 'Detached HEAD; select a branch with --branch <name>' >&2
          exit 2
        fi
        branch=''${current#refs/heads/}
      fi
      ref="refs/heads/$branch"
      if [[ ! "$ref" =~ ^refs/heads/[a-zA-Z0-9@._/-]+$ ]]; then
        echo "Unsupported branch: $branch" >&2
        exit 2
      fi
      git check-ref-format "$ref"
      if git symbolic-ref --quiet "$ref" >/dev/null; then
        echo "Refusing to update symbolic branch $ref; select a direct branch" >&2
        exit 1
      fi
      source="$host:$path"
      fetch=(git -c fetch.prune=false -c fetch.pruneTags=false fetch --no-tags --no-recurse-submodules --refmap=)
      if [[ "$ref" == "$current" ]]; then
        if [[ -n "$(git status --porcelain --untracked-files=normal --ignore-submodules=none)" ]]; then
          echo 'Commit or stash local changes before receiving into the current branch' >&2
          exit 1
        fi
        temporary="refs/git-receive/$$"
        trap 'git update-ref -d "$temporary"' EXIT
        "''${fetch[@]}" "$source" "+$ref:$temporary"
        fetched=$(git rev-parse --verify "$temporary^{commit}")
        if [[ "$(git symbolic-ref --quiet HEAD || true)" != "$ref" ]]; then
          echo 'Current branch changed during fetch; fetched history remains in FETCH_HEAD. Switch back before retrying' >&2
          exit 1
        fi
        if ! git merge --ff-only --no-autostash "$fetched"; then
          printf 'Could not fast-forward %s from %s. Fetched history remains in FETCH_HEAD; inspect it with: git log --left-right --graph %q\n' "$ref" "$source" "$ref...FETCH_HEAD" >&2
          exit 1
        fi
      else
        # Fetch protects branches checked out in any worktree and rejects rewinds.
        if ! "''${fetch[@]}" "$source" "$ref:$ref"; then
          printf 'Could not receive %s from %s. Resolve the fetch error above; if histories diverged, inspect FETCH_HEAD before merging or rebasing.\n' "$ref" "$source" >&2
          exit 1
        fi
      fi
    '';
  };
in {
  options.modules.development.instructions = {
    enable = mkOption {
      type = types.bool;
      default = config.modules.development.enable;
      description = "Whether to install shared personal agent instructions.";
    };

    authorizedGitKeys = mkOption {
      type = types.listOf types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJffcTjACQ0XJLO7iv16MVgM783KAn1q1LsaIT/kWqNn phil+agent@kitten.sh"
      ];
      description = ''
        Public SSH keys granted Git-only access when shared instructions are enabled.
        Independent of agent account enablement. Set to an empty list to opt out.
      '';
    };

    extra = mkOption {
      type = types.lines;
      default = "";
      description = "Additional instructions for this account. Public text only; stored in the Nix store.";
    };

    text = mkOption {
      type = types.lines;
      readOnly = true;
      default = sharedInstructions
        + optionalString isAgent ("\n" + agentInstructions)
        + optionalString (cfg.extra != "") ("\n" + cfg.extra + "\n");
      description = "Shared personal instructions, including account-specific additions.";
    };
  };

  config = mkIf cfg.enable {
    modules.git.sshAccess = {
      enable = mkDefault true;
      authorizedKeys = cfg.authorizedGitKeys;
    };
    programs.git.settings.alias.send = mkIf config.modules.git.enable
      "!${send}/bin/git-send";
    programs.git.settings.alias.receive = mkIf config.modules.git.enable
      "!${receive}/bin/git-receive";
    home.file."${config.modules.git.directory}/AGENTS.md".text = cfg.text;
  };
}
