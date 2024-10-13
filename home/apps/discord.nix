{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.discord = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Discord.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.discord.enable) {
    home.packages = with pkgs; [ vesktop ];
  };
}
