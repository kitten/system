{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.hyprland = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable Hyprland configuration.";
      type = types.bool;
    };
  };

  config = mkIf cfg.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;

      package = null;
      portalPackage = null;
      systemd.enable = false;
      xwayland.enable = false;

      settings = {
        "$mod" = "SUPER";

        general = {
          gaps_out = 10;
        };

        input = {
          kb_options = "ctrl:nocaps";
          touchpad = {
            clickfinger_behavior = true;
            tap-to-click = false;
            tap-and-drag = false;
            scroll_factor = 0.2;
          };
        };

        monitor = [
          "eDP-1, preferred, 0x0, 1.6"
          "eDP-1, addreserved, 35, 0, 0, 0"
        ];

        debug = {
          error_position = 1;
        };

        bind = [
          "$mod, Q, exec, uwsm app -- ghostty"
        ];
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      hyprcursor.enable = true;
      x11.enable = true;
      package = pkgs.apple-cursor;
      name = "macOS";
      size = 28;
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
      font = {
        name = "Inter";
        size = 11;
      };
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "Noto Color Emoji" ];
        sansSerif = [ "Inter" "Noto Color Emoji" ];
        monospace = [ "Dank Mono" "Roboto Mono" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
