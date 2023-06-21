{ pkgs, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) hex;
in {
  services.mako = {
    enable = true;
    font = "Inter 12";
    defaultTimeout = 2600;
    backgroundColor = "#99${hex.split}";
    textColor = "#FF${hex.white}";
    borderRadius = 3;
    borderSize = 0;
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "Lightweight Wayland notification daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };

    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notification";
      ExecStart = "${pkgs.mako}/bin/mako";
      ExecReload = "${pkgs.mako}/bin/makoctl reload";
    };
  };
}
