{ lib, config, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.rawaccel = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable Yeetmouse (fork of Leetmouse / Rawaccel for Linux).";
      type = types.bool;
    };
  };

  config = mkIf cfg.rawaccel.enable {
    hardware.yeetmouse = {
      enable = true;
      sensitivity = 0.56;
      offset = 5.9;
      inputCap = 35.0;
      preScale = 0.17;
      rotation.angle = 3.0;
      mode.jump = {
        acceleration = 3.97;
        midpoint = 4.1;
        smoothness = 1.0;
        useSmoothing = true;
      };
    };
  };
}
