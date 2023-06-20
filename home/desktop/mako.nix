{ pkgs, ... }:

{
  services.mako = {
    enable = true;
    font = "sans 10";
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "Lightweight Wayland notification daemon";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
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
