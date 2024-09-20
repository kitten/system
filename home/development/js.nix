{ lib, config, ... }:

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
  };

  config = mkIf cfg.js.enable {
    age.secrets."npmrc" = {
      symlink = true;
      path = "${home}/.npmrc";
      file = ./encrypt/npmrc.age;
    };

    home.file.".yarnrc".text = ''
      disable-self-update-check true
    '';

    home.file.".bunfig.toml".text = ''
      telemetry = false

      [install]
      auto = "disable"
      globalDir = "~/.local/share/bun/global"
      globalBinDir = "~/.local/share/bun"

      [install.cache]
      dir = "~/.cache/bun/install/cache"
    '';
  };
}
