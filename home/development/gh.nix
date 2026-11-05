{ lib, config, pkgs, osConfig, ... }:

let
  cfg = config.modules.development.gh;
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
  files = auth.runtimeFiles "${config.home.username}-gh" cfg.environmentFile osConfig.age.secrets;
  configuration = pkgs.runCommand "gh-managed-config" { } ''
    mkdir -p $out
    printf 'git_protocol: ssh\nprompt: disabled\n' > $out/config.yml
    printf 'github.com:\n    git_protocol: ssh\n' > $out/hosts.yml
  '';
  package = pkgs.writeShellScriptBin "gh" ''
    set -euo pipefail
    # Locate the command after supported global flags; reject unknown prefixes.
    args=("$@")
    while [ "$#" -gt 0 ]; do
      case "$1" in
        -R|--repo) [ "$#" -ge 2 ] || exit 2; shift 2 ;;
        --repo=*|-R?*) shift ;;
        --help|--version|-h|-v) exec ${pkgs.gh}/bin/gh "$@" ;;
        -*) echo "Unsupported gh global flag: $1" >&2; exit 2 ;;
        auth)
          if [ "''${2-}" != status ]; then
            echo 'gh authentication is managed by Nix; only auth status is allowed.' >&2
            exit 1
          fi
          break ;;
        *) break ;;
      esac
    done
    # Never fall back to inherited credentials, hosts.yml, or Keychain.
    unset GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN
    ${lib.concatMapStringsSep "\n" (file: ''
      if [ ! -r ${lib.escapeShellArg file} ]; then
        echo 'Managed gh token file is unavailable.' >&2
        exit 1
      fi
      . ${lib.escapeShellArg file}
    '') files}
    if [ -z "''${GH_TOKEN:-}" ]; then
      echo 'Configure modules.development.gh.environmentFile with a restricted GH_TOKEN.' >&2
      exit 1
    fi
    unset GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN
    export GH_TOKEN GH_CONFIG_DIR=${configuration} GH_HOST=github.com GH_PROMPT_DISABLED=1
    exec ${pkgs.gh}/bin/gh "''${args[@]}"
  '';
in {
  options.modules.development.gh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.development.enable && !(config.modules.agent.enable or false);
      description = "Install operator gh with managed authentication and immutable configuration.";
    };
    environmentFile = auth.environmentFileOptions ./encrypt/gh.env.age // {
      enable = lib.mkEnableOption ''
        an agenix-managed GH_TOKEN for operator gh. Use a fine-grained PAT with
        Contents read-only and only the required repository permissions. Revoke
        previous broad credentials separately; this wrapper does not remove them.
        Command restrictions are guardrails, not isolation from the same user
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
  };
}
