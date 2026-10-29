{ lib, config, pkgs, inputs, helpers, ... }:

with lib;
let
  cfg = config.modules.agent;
  knownHostsFile = pkgs.writeText "agent-known_hosts" (concatStringsSep "\n" cfg.knownHosts + "\n");
  signingKey = if cfg.signing.key != null then cfg.signing.key else cfg.sshKey;

  # Secret options take runtime paths (agenix: /run/agenix/..., sops-nix:
  # /run/secrets/...), never key material or a store path.
  secretPath = types.strMatching "/run/[^\n]+" // {
    description = "runtime secret path under /run (e.g. /run/agenix/...)";
  };

  # gh reads GH_TOKEN; outside the service (where the env file is already loaded)
  # take it from the token file, in a subshell, for gh only.
  ghCredential = pkgs.writeShellScript "agent-gh-credential" ''
    if [ -z "''${GH_TOKEN:-}" ] && [ -r ${escapeShellArg cfg.tokenEnvFile} ]; then
      set -a; . ${escapeShellArg cfg.tokenEnvFile}; set +a
    fi
    exec ${pkgs.gh}/bin/gh auth git-credential "$@"
  '';
in {
  imports = [
    inputs.android-sdk.hmModules.android
    ../base/shell.nix
    ../base/tools.nix
    ../base/tmux.nix
    ../base/xdg.nix
    ../base/ssh.nix
    ../base/git.nix
    ../development
  ];

  options.modules.agent = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to give this user an agent's own git/GitHub identity.";
      type = types.bool;
    };

    name = mkOption {
      example = "kitten-agent";
      description = "Commit author name.";
      type = types.str;
    };

    email = mkOption {
      example = "phil+agent@kitten.sh";
      description = "Commit author email (an address of the agent's GitHub account).";
      type = types.str;
    };

    sshKey = mkOption {
      example = "/run/agenix/agent-ssh";
      description = "Path of the private SSH key git authenticates with.";
      default = null;
      type = types.nullOr secretPath;
    };

    tokenEnvFile = mkOption {
      default = null;
      example = "/run/agenix/agent.env";
      description = ''
        Path of an env file (KEY=value) with GH_TOKEN, for gh and git over HTTPS,
        and any other credentials of the account's CLIs (see loadEnvInShell).
      '';
      type = types.nullOr secretPath;
    };

    loadEnvInShell = mkOption {
      default = true;
      example = false;
      description = "Whether zsh sources tokenEnvFile at startup, including SSH logins and scripts.";
      type = types.bool;
    };

    knownHosts = mkOption {
      # https://api.github.com/meta
      default = [
        "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
        "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
        "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
      ];
      description = "Pinned SSH host keys (known_hosts lines); git never trusts a first-seen key.";
      type = types.listOf types.str;
    };

    signing = {
      enable = mkOption {
        default = false;
        example = true;
        description = "Whether to SSH-sign commits and tags (add the public key to the account as a signing key).";
        type = types.bool;
      };

      key = mkOption {
        default = null;
        example = "/run/agenix/agent-signing";
        description = "Private key to sign with; defaults to sshKey.";
        type = types.nullOr secretPath;
      };
    };
  };

  config = mkIf cfg.enable {
    modules.development.js.projectBinInPath = mkForce false;

    # Session variables load before .zshrc; non-terminal shells can skip the UI.
    programs.zsh.initContent = mkBefore ''
      [[ -t 0 && -t 1 ]] || return 0
    '';

    assertions = [
      {
        assertion = !cfg.signing.enable || signingKey != null;
        message = "modules.agent: signing requires signing.key or sshKey.";
      }
      {
        assertion = config.modules.git.user.email != "phil@kitten.sh";
        message = "modules.agent: configure the agent's own Git identity.";
      }
      {
        assertion = !config.programs.gpg.enable && !config.services.gpg-agent.enable;
        message = "modules.agent: GPG and gpg-agent must remain disabled.";
      }
    ];

    xdg.runtimeDir = helpers.mkIfDarwin "$(getconf DARWIN_USER_TEMP_DIR)";
    home.sessionVariables = helpers.mkIfDarwin {
      TMPDIR = "$(getconf DARWIN_USER_TEMP_DIR)";
      NPM_CONFIG_TMP = mkForce "$(getconf DARWIN_USER_TEMP_DIR)/npm";
    };

    programs.zsh.envExtra = mkIf (cfg.tokenEnvFile != null && cfg.loadEnvInShell) ''
      if [[ -r ${escapeShellArg cfg.tokenEnvFile} ]]; then
        set -a; . ${escapeShellArg cfg.tokenEnvFile}; set +a
        export GITHUB_TOKEN="''${GITHUB_TOKEN:-''${GH_TOKEN:-}}"
      fi
    '';

    modules.git = {
      user = { inherit (cfg) name email; };
      signingKey = if cfg.signing.enable then signingKey else null;
    };

    # Agent accounts use their own Git identity and never start a GPG agent.
    programs.gpg.enable = mkDefault false;
    services.gpg-agent.enable = mkDefault false;

    programs.git = {
      signing = {
        signByDefault = cfg.signing.enable;
        key = if cfg.signing.enable then signingKey else null;
        format = mkIf cfg.signing.enable "ssh";
      };
      settings = mkMerge [
        {
          commit.gpgSign = mkOverride 60 false;
          tag.gpgSign = mkOverride 60 false;
          push.gpgSign = mkOverride 60 false;
          # This key only, no ssh-agent, pinned host keys.
          core.sshCommand = mkIf (cfg.sshKey != null) (concatStringsSep " " [
            "${pkgs.openssh}/bin/ssh"
            "-i ${cfg.sshKey}"
            "-o IdentitiesOnly=yes"
            "-o IdentityAgent=none"
            "-o UserKnownHostsFile=${knownHostsFile}"
            "-o StrictHostKeyChecking=yes"
          ]);
        }
        (mkIf (cfg.tokenEnvFile != null) {
          "credential \"https://github.com\"".helper = [ "" "!${ghCredential}" ];
          "credential \"https://gist.github.com\"".helper = [ "" "!${ghCredential}" ];
        })
        (mkIf cfg.signing.enable {
          gpg.ssh.program = "${pkgs.openssh}/bin/ssh-keygen";
          commit.gpgSign = mkForce true;
          tag.gpgSign = mkForce true;
        })
      ];
    };

    home.packages = [ pkgs.gh ];
  };
}
