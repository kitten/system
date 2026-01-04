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
      offset = 11.6;
      inputCap = 35.4;
      preScale = 800.0 / 1600.0;
      rotation.angle = 5.0;
      mode.classic = {
        acceleration = 0.0398 * 1.3333;
        exponent = 3.28;
        smoothCap = 5.0;
        useSmoothing = true;
      };
    };
  };
}
