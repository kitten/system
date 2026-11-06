{ lib, helpers, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.xdg;
in {
  options = {
    modules.xdg = {
      enable = mkOption {
        default = true;
        description = "XDG Configuration";
        type = types.bool;
      };
    };
    xdg.runtimeDir = mkOption {
      type = types.nullOr types.str;
      default = if helpers.isDarwin then "$(mktemp -d)" else null;
      apply = (val: if val != null then (toString val) else null);
    };
  };

  config = mkIf cfg.enable {
    home.activation.xdgDirectories = hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
      (concatMapStringsSep "\n" (directory: ''
        run mkdir -p -m 0700 -- ${escapeShellArg directory}
        run chmod 0700 -- ${escapeShellArg directory}
      '') (unique [
        config.xdg.configHome
        config.xdg.dataHome
        config.xdg.stateHome
        config.xdg.cacheHome
      ]));

    xdg = {
      enable = true;
      userDirs = {
        enable = mkDefault helpers.isLinux;
        setSessionVariables = true;
      };
      systemDirs.data = mkIf helpers.isLinux [
        "/usr/share"
        "/usr/local/share"
      ];
    };

    home.sessionVariables = mkIf helpers.isDarwin {
      XDG_RUNTIME_DIR = optionalString (config.xdg.runtimeDir != null) config.xdg.runtimeDir;
    };
  };
}
