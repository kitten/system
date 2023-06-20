{ pkgs, hyprland, ... }:

{
  imports = [
    hyprland.homeManagerModules.default
  ];

  fonts.fontconfig.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      bind = SUPER, Return, exec, wezterm
    '';
  };

  services.mako = {
    enable = true;
    font = "sans 10";
  };

  systemd.user = {
    services.mako = {
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

    sessionVariables = {
      "NIXOS_OZONE_WL" = "1"; # force ozone-based electron apps to use Wayland
      "MOZ_ENABLE_WAYLAND" = "1"; # force Firefox to use Wayland
      "MOZ_WEBRENDER" = "1";
    };
  };
}
