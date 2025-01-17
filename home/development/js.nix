{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.development;
  home = config.home.homeDirectory;
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
    age.secrets."npmrc" = {
      symlink = true;
      path = "${home}/.npmrc";
      file = ./encrypt/npmrc.age;
    };

    home.sessionPath = [
      "./node_modules/.bin"
      "$HOME/.local/share/pnpm"
    ];

    home.sessionVariables = {
      PNPM_HOME = "$HOME/.local/share/pnpm";
      BUN_RUNTIME_TRANSPILER_CACHE_PATH = mkIf cfg.js.bun "$HOME/.cache/bun/install/cache/@t@";
      COREPACK_ENABLE_AUTO_PIN = "0";
    };

    home.file.".yarnrc".text = ''
      disable-self-update-check true
    '';

    home.file.".bunfig.toml".text = mkIf cfg.js.bun ''
      telemetry = false

      [install]
      auto = "disable"
      globalDir = "~/.local/share/bun/global"
      globalBinDir = "~/.local/share/bun"

      [install.cache]
      dir = "~/.cache/bun/install/cache"
    '';

    home.packages = with pkgs; [
      corepack_22
      nodejs_22
    ] ++ optionals cfg.js.bun [ pkgs.bun ];
  };
}
