{ pkgs, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) hex;
  inherit (pkgs) hyprland swayidle;
  swaylock = pkgs.swaylock-effects;
in {
  services.swayidle = let
    dpms = "${hyprland}/bin/hyprctl dispatch dpms";
    lock = "${swaylock}/bin/swaylock";
  in {
    enable = true;
    package = swayidle;
    systemdTarget = "graphical-session.target";
    extraArgs = [
      "idlehint 60"
    ];
    events = [
      {
        event = "lock";
        command = "${lock}";
      }
      {
        event = "before-sleep";
        command = "${lock}";
      }
      {
        event = "after-resume";
        command = "${dpms} on";
      }
    ];
    timeouts = [
      {
        timeout = 120;
        command = "systemctl suspend-then-hibernate";
        resumeCommand = "${dpms} on";
      }
    ];
  };

  programs.swaylock = {
    enable = true;
    package = swaylock;
    settings = {
      screenshots = true;
      clock = true;
      indicator = true;
      indicator-radius = 100;
      fade-in = 0.2;
      effect-blur = "16x3";
      effect-vignette = "0.5:0.5";
      timestr = "%H:%M";
      font = "Inter";
      key-hl-color = "${hex.brightBlue}";
      inside-color = "00000088";
      inside-caps-lock-color = "00000088";
      inside-ver-color = "00000088";
      inside-wrong-color = "00000088";
      inside-clear-color = "${hex.cyan}";
      text-color = "${hex.white}";
      text-clear-color = "${hex.white}";
      text-caps-lock-color = "${hex.white}";
      text-ver-color = "${hex.white}";
      text-wrong-color = "${hex.white}";
      layout-text-color = "${hex.white}";
      ring-color = "${hex.blue}";
      ring-caps-lock-color = "${hex.brightBlue}";
      ring-ver-color = "${hex.purple}";
      ring-wrong-color = "${hex.red}";
      ring-clear-color = "${hex.cyan}";
    };
  };
}
