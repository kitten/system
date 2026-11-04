{ lib, config, pkgs, user, ... }:

with lib;
let
  cfg = config.modules.development.instructions;
  sharedInstructions = ''
    - Shared repos live at `~/git/<org>/<repo>`; clone with `git get <org>/<repo>`
      - Use SSH remotes
      - For forks, `origin` is the fork and `upstream` the canonical repo. The local default branch tracks `upstream/<default>`
      - After adding any remote, run `git normalize-remotes`
      - Fetch third-party PRs with `git pr <number>` (no fork remote needed; detached HEAD)
      - Check branch/status and preserve unrelated changes. Other threads may share checkouts
    - Tools come from Nix; use `nix run nixpkgs#tool -- args` for additional tools
      - Don't directly alter live configs or tooling outside ~/git unless requested
      - Enter configured devshells with `nix develop -c <command>` or `direnv exec . <command>` as needed; shells may not load them automatically
      - Don't assume Homebrew, nvm, or Cargo paths
      - Check pinned/installed versions and supported options
      - Shells use zsh. Quote search globs
    - Your session is headless. Don't depend on a desktop login
      - While working, prefer headless/offscreen harnesses for testing, screenshots, or interactive checks
      - Discover sessions, ports, and flags through CLI help rather than guessing
    - Use repo-declared preferences, package managers, scripts, and formatters
      - Read each checkout's own agent instructions before editing there
      - Check dependencies against the current checkout before diagnosing test failures
      - For cross-repo testing, verify resolved packages and built artifacts, including native binaries; links can alter resolution
      - When benchmarking, prefer representative workloads against the intended baseline
      - Keep changes and explanations focused. Avoid redundant docs/comments and committed temporary artifacts
  '';
  promote = pkgs.writeShellApplication {
    name = "git-promote";
    runtimeInputs = [ pkgs.git pkgs.openssh ];
    text = ''
      local_only=false
      force=false
      branch=""
      while [[ $# -gt 0 ]]; do
        case "$1" in
        --local-only) local_only=true ;;
        --force-with-lease) force=true ;;
        --branch)
          if [[ $# -lt 2 || -z "$2" ]]; then
            echo '--branch requires a branch name' >&2
            exit 2
          fi
          branch=$2
          shift
          ;;
        --help | -h)
          echo 'Usage: git promote [--local-only] [--force-with-lease] [--branch name] [user@host|host]'
          exit 0
          ;;
        *) break ;;
        esac
        shift
      done
      if [[ $# -gt 1 || ''${1-} == -* ]]; then
        echo 'Usage: git promote [--local-only] [--force-with-lease] [--branch name] [user@host|host]' >&2
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
      mode=ff
      if $force; then
        mode=lease
        tip=$(git ls-remote --refs "$host:$path" "$ref")
        lease=("--force-with-lease=$ref:''${tip%%$'\t'*}")
      fi

      receive=()
      if ! $local_only; then
        receive=("--receive-pack=git-receive-pack --promote=$mode:$ref:$sha")
      fi
      exec git -c push.followTags=false -c push.recurseSubmodules=no push \
        "''${receive[@]}" "''${lease[@]}" "$host:$path" "$sha:$ref"
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
      default = sharedInstructions + optionalString (cfg.extra != "") ("\n" + cfg.extra + "\n");
      description = "Shared personal instructions, including account-specific additions.";
    };
  };

  config = mkIf cfg.enable {
    modules.git.sshAccess = {
      enable = mkDefault true;
      authorizedKeys = cfg.authorizedGitKeys;
    };
    programs.git.settings.alias.promote = mkIf config.modules.git.enable
      "!${promote}/bin/git-promote";
    home.file."${config.modules.git.directory}/AGENTS.md".text = cfg.text;
  };
}
