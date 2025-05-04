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

        debug.error_position = 1;
        misc.middle_click_paste = false;

        monitor = [
          "eDP-1, preferred, 0x0, 1.6"
          "eDP-1, addreserved, 35, 0, 0, 0"
        ];

        bind = [
          "$mod, T, exec, uwsm-app ghostty"
          "$mod, B, exec, uwsm-app zen-beta"
          "$mod, W, killactive"
        ];
      };
    };

    services = {
      hyprpolkitagent.enable = true;
      hypridle = {
        enable = true;
        package = null;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 330;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 600;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
    };

    programs.hyprlock = {
      enable = true;
      package = null;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 10;
          hide_cursor = true;
          no_fade_in = false;
        };
        background = [
          {
            path = "";
            blur_passes = 3;
            blur_size = 8;
          }
        ];
        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            shadow_passes = 2;
          }
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
