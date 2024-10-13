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
      parameters = {
        Sensitivity = 0.56;
        Acceleration = 3.97;
        AccelerationMode = "jump";
        Exponent = 1.0;
        InputCap = 35.0;
        Midpoint = 4.1;
        Offset = 5.9;
        PreScale = 0.17;
        RotationAngle = 0.05;
        ScrollsPerTick = 3;
        UseSmoothing = true;
      };
    };
  };
}
