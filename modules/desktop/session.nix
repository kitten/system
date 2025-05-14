{ lib, config, pkgs, user, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.session = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable session and desktop environment.";
      type = types.bool;
    };
  };

  config = mkIf cfg.session.enable {
    users.users."${user}".extraGroups = [ "video" ];

    boot = {
      plymouth.enable = true;
      initrd.verbose = mkDefault false;
      consoleLogLevel = 0;
    };

    environment.sessionVariables = {
      GSK_RENDERER = mkDefault "ngl";
      QT_QPA_PLATFORM = mkDefault "wayland;xcb";
      GDK_BACKEND = mkDefault "wayland,x11,*";
      SDL_VIDEODRIVER = mkDefault "wayland,x11";
      NIXOS_OZONE_WL = mkDefault "1";
    };

    services = {
      greetd = {
        enable = true;
        settings.terminal.vt = 1;
      };
      upower.enable = true;
      gvfs.enable = true;
      logind = {
        powerKey = "suspend";
        powerKeyLongPress = "poweroff";
        lidSwitch = "suspend";
      };
    };

    programs = {
      regreet.enable = true;
      hyprlock.enable = true;
      hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };
    };

    security = {
      polkit.enable = true;
      pam.services.hyprlock = {};
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };
  };
}
