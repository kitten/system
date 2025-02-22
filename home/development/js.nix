{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development;
  NPMRC_PATH = "${config.xdg.configHome}/npm/npmrc";
  BUNFIG_PATH = "${config.xdg.configHome}/.bunfig.toml";
  BUN_HOME = "${config.xdg.dataHome}/bun";
  PNPM_HOME = "${config.xdg.dataHome}/pnpm";
in {
  options.modules.development.js = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable JS configuration.";
      type = types.bool;
    };

    bun = mkOption {
      default = cfg.js.enable;
      type = types.bool;
    };
  };

  config = mkIf cfg.js.enable {
    age.secrets."${NPMRC_PATH}" = {
      symlink = true;
      path = "${NPMRC_PATH}";
      file = ./encrypt/npmrc.age;
    };

    home.sessionPath = [
      "./node_modules/.bin"
      PNPM_HOME
    ] ++ optionals cfg.js.bun [ BUN_HOME ];

    home.sessionVariables = {
      inherit PNPM_HOME;
      BUN_RUNTIME_TRANSPILER_CACHE_PATH = mkIf cfg.js.bun "${config.xdg.cacheHome}/bun/install/cache/@t@";
      NODE_REPL_HISTORY = "${config.xdg.stateHome}/node_repl_history";
      NPM_CONFIG_USERCONFIG = "${NPMRC_PATH}";
      NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
      NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
      VOLTA_HOME = "${config.xdg.dataHome}/volta";

      COREPACK_ENABLE_AUTO_PIN = "0"; # disable corepack creating packageManager entries
      COREPACK_INTEGRITY_KEYS = "0";
    };

    home.file.".yarnrc".text = ''
      disable-self-update-check true
    '';

    home.file."${BUNFIG_PATH}".text = mkIf cfg.js.bun ''
      telemetry = false

      [install]
      auto = "disable"
      globalDir = "${BUN_HOME}/global"
      globalBinDir = "${BUN_HOME}"

      [install.cache]
      dir = "${config.xdg.cacheHome}/bun"
    '';

    home.packages = with pkgs; [
      corepack_22
      nodejs_22
    ] ++ optionals cfg.js.bun [ pkgs.bun ];
  };
}
