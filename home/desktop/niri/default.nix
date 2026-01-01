{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.niri = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable Niri configuration.";
      type = types.bool;
    };
  };

  config = mkIf cfg.niri.enable {
    xdg.configFile."niri/config.kdl".text = (builtins.readFile ./config.kdl);
  };
}
