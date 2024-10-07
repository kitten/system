{ lib, config, user, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;
  yeetmouse = import ../../lib/pkgs/yeetmouse.nix pkgs;
in {
  options.modules.desktop.services = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable services.";
      type = types.bool;
    };
  };

  config = mkIf cfg.services.enable {
    users.users."${user}".extraGroups = [ "video" ];

    services = {
      printing.enable = true;
      flatpak.enable = true;
      colord.enable = true;
    };

    boot.extraModulePackages = [ yeetmouse ];
    environment.systemPackages = [ yeetmouse ];
    services.udev = {
      packages = [ yeetmouse ];
      extraRules = let
        echo = "${pkgs.coreutils}/bin/echo";
        yeetmouseConfig = pkgs.writeShellScriptBin "yeetmouseConfig" ''
          ${echo} "2.89" > /sys/module/leetmouse/parameters/Acceleration
          ${echo} "4" > /sys/module/leetmouse/parameters/AccelerationMode
          ${echo} "0.4" > /sys/module/leetmouse/parameters/Exponent
          ${echo} "17.2" > /sys/module/leetmouse/parameters/InputCap
          ${echo} "6.54" > /sys/module/leetmouse/parameters/Midpoint
          ${echo} "7.53" > /sys/module/leetmouse/parameters/Offset
          ${echo} "0" > /sys/module/leetmouse/parameters/OutputCap
          ${echo} "0.17" > /sys/module/leetmouse/parameters/PreScale
          ${echo} "0.0514872" > /sys/module/leetmouse/parameters/RotationAngle
          ${echo} "3" > /sys/module/leetmouse/parameters/ScrollsPerTick
          ${echo} "0.56" > /sys/module/leetmouse/parameters/Sensitivity
          ${echo} "1" > /sys/module/leetmouse/parameters/UseSmoothing
          ${echo} "1" > /sys/module/leetmouse/parameters/update
        '';
      in ''
        SUBSYSTEMS=="usb|input|hid", ATTRS{bInterfaceClass}=="03", ATTRS{bInterfaceSubClass}=="01", ATTRS{bInterfaceProtocol}=="02", ATTRS{bInterfaceNumber}=="00", RUN+="${yeetmouseConfig}/bin/yeetmouseConfig"
      '';
    };
  };
}
