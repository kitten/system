{ pkgs, ... }:

{
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/pixelwallpaper.jpg
    wallpaper = eDP-1, ~/Pictures/pixelwallpaper.jpg
  '';

  systemd.user.services.hyprpaper = {
    Unit = {
      Description = "Blazing fast Wayland wallpaper utility";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      KillMode = "mixed";
    };
  };
}
