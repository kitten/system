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
    # Never fall back to inherited credentials, hosts.yml, or Keychain.
    unset GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN
    ${lib.concatMapStringsSep "\n" (file: ''
      . ${lib.escapeShellArg file}
    '') files}
    if [ -z "''${GH_TOKEN:-}" ]; then
      echo 'Configure modules.development.gh.environmentFile with a restricted GH_TOKEN.' >&2
      exit 1
    fi
    unset GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN
    export GH_TOKEN GH_CONFIG_DIR=${configuration} GH_HOST=github.com GH_PROMPT_DISABLED=1
    exec ${pkgs.gh}/bin/gh "$@"
  '';
in {
  options.modules.development.gh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.development.enable && !(config.modules.agent.enable or false);
      description = "Install operator gh with managed authentication and immutable configuration.";
    };
    # Owner-only 0400 runtime file, installed by modules/base/home.nix.
    # Use a fine-grained PAT with Contents read-only; revoke old broad tokens separately.
    environmentFile = auth.environmentFileOptions ./encrypt/gh.env.age;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
  };
}
