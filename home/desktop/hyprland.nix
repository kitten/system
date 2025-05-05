{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;

  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
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
        general = {
          gaps_out = 10;
          resize_on_border = true;
          hover_icon_on_border = false;
          extend_border_grab_area = 10;
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

        gestures = {
          workspace_swipe = true;
          workspace_swipe_invert = false;
          workspace_swipe_distance = 450;
        };

        debug.error_position = 1;
        misc.middle_click_paste = false;

        monitor = [
          "eDP-1, preferred, 0x0, 1.6"
          "eDP-1, addreserved, 35, 0, 0, 0"
        ];

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPERSHIFT, mouse:272, resizewindow"
        ];

        bindel = [
          ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 3%+"
          ", XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 3%-"
          ", XF86MonBrightnessDown, exec, ${brightnessctl} s 10%-"
          ", XF86MonBrightnessUp, exec, ${brightnessctl} set +10%"
        ];

        bindl = [
          ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, ${playerctl} play-pause"
          ", XF86AudioPause, exec, ${playerctl} play-pause"
          ", XF86AudioNext, exec, ${playerctl} next"
          ", XF86AudioPrev, exec, ${playerctl} previous"
        ];

        bind = [
          "SUPER, T, exec, uwsm-app ghostty"
          "SUPER, B, exec, uwsm-app zen-beta"
          "SUPER, W, killactive"
        ];

        windowrule = [
          "float, class:zen-beta,initialTitle:(Picture-in-Picture)"
        ];
      };
    };

    services = {
      hyprpolkitagent.enable = true;
      playerctld.enable = true;
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
