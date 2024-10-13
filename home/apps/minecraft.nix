{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.minecraft = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Minecraft via Prism.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.minecraft.enable) {
    home.packages = with pkgs; [
      (prismlauncher.override {
        jdks = [ temurin-bin-21 ];
      })
    ];
  };
}
