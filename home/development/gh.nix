{ lib, config, pkgs, osConfig, ... }:

let
  cfg = config.modules.development.gh;
  auth = import ../../lib/shell-env-wrapper.nix { inherit lib pkgs; };
  files = auth.runtimeFiles "${config.home.username}-gh" cfg.environmentFile osConfig.age.secrets;
  package = pkgs.writeShellScriptBin "gh" ''
    set -euo pipefail
    unset GH_TOKEN
    ${lib.concatMapStringsSep "\n" (file: ". ${lib.escapeShellArg file}") files}
    : "''${GH_TOKEN:?Configure modules.development.gh.environmentFile with a restricted GH_TOKEN.}"
    unset GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN
    export GH_TOKEN GH_CONFIG_DIR=${lib.escapeShellArg "${config.xdg.configHome}/gh"} GH_HOST=github.com GH_PROMPT_DISABLED=1
    exec ${pkgs.gh}/bin/gh "$@"
  '';
in {
  options.modules.development.gh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.development.enable && !(config.modules.agent.enable or false);
      description = "Install operator gh with managed authentication and a read-only hosts file.";
    };
    environmentFile = auth.environmentFileOptions ./encrypt/gh.env.age;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ package ];
    xdg.configFile."gh/hosts.yml".text = ''
      github.com:
          git_protocol: ssh
    '';
  };
}
