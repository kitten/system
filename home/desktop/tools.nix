{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.tools = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable basic desktop tools.";
      type = types.bool;
    };
  };

  config = mkIf cfg.tools.enable {
    home.packages = with pkgs; [
      pwvucontrol
      mission-center
    ];
  };
}
