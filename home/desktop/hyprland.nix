{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;

  system-shell = "${getExe pkgs.system-shell}";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";

  hyprshot = getExe (pkgs.hyprshot.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      wrapProgram $out/bin/hyprshot \
        --set HYPRSHOT_DIR "${config.xdg.userDirs.pictures}/Screenshots"
    '';
  }));
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
      plugins = with pkgs.hyprlandPlugins; [ hyprspace ];

      settings = {
        source = [ "/etc/hypr/hyprland.conf" ];

        general = {
          gaps_out = 9;
          gaps_in = 4;
          allow_tearing = true;
          resize_on_border = true;
          hover_icon_on_border = false;
          no_border_on_floating = true;
          extend_border_grab_area = 10;
          border_size = 1;
          "col.active_border" = "0xB35A5A5A";
          "col.inactive_border" = "0x8C3A3A3A";
        };

        decoration = {
          rounding = 9;
          dim_inactive = true;
          dim_strength = 0.12;

          blur = {
            enabled = true;
            size = 6;
            passes = 4;
            contrast = 0.74;
            brightness = 0.45;
            vibrancy = 0.15;
            vibrancy_darkness = 0.1;
            ignore_opacity = false;
            popups_ignorealpha = 0.1;
            input_methods_ignorealpha = 0.1;
            noise = 0.012;
          };

          shadow = {
            color = "0x81000000";
            range = 40;
            render_power = 2;
            offset = "5, 5";
          };
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_invert = false;
          workspace_swipe_cancel_ratio = 0.2;
          workspace_swipe_distance = 560;
        };

        misc = {
          middle_click_paste = false;
          focus_on_activate = true;
          key_press_enables_dpms = true;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          vrr = 1;
        };

        debug.error_position = 1;

        plugin.overview = {
          autoDrag = true;
          hideOverlayLayers = false;
          exitOnSwitch = true;
          reverseSwipe = true;
          dragAlpha = 0.85;
          workspaceMargin = 16;
          panelHeight = 150;
          reservedArea = 38;
        };

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPERSHIFT, mouse:272, resizewindow"
        ];

        bindel = [
          ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 3%+"
          ", XF86AudioLowerVolume, exec, ${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 3%-"
          ", XF86MonBrightnessDown, exec, ${brightnessctl} set 3%-"
          ", XF86MonBrightnessUp, exec, ${brightnessctl} set +3%"
        ];

        bindl = [
          ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ", XF86AudioPlay, exec, ${system-shell} play_pause"
          ", XF86AudioPause, exec, ${system-shell} play_pause"
          ", XF86AudioNext, exec, ${system-shell} play_next"
          ", XF86AudioPrev, exec, ${system-shell} play_previous"
        ];

        bindp = [
          ", F11, fullscreen, 0"
          "SUPER, W, killactive"

          "SUPER, H, movefocus, l"
          "SUPER, J, movefocus, d"
          "SUPER, K, movefocus, u"
          "SUPER, L, movefocus, r"
          "SUPER_SHIFT, H, movewindow, l"
          "SUPER_SHIFT, J, movewindow, d"
          "SUPER_SHIFT, K, movewindow, u"
          "SUPER_SHIFT, L, movewindow, r"

          "SUPER_CONTROL, K, overview:toggle, all"
          "SUPER_CONTROL, H, workspace, m-1"
          "SUPER_CONTROL, L, workspace, m+1"
          "SUPER_CONTROL_SHIFT, H, movetoworkspace, -1"
          "SUPER_CONTROL_SHIFT, L, movetoworkspace, +1"

          "SUPER, up, overview:toggle, all"
          "SUPER, left, workspace, m-1"
          "SUPER, right, workspace, m+1"
          "SUPER_SHIFT, left, movetoworkspace, m-1"
          "SUPER_SHIFT, right, movetoworkspace, m+1"

          "SUPER_CONTROL, left, focusmonitor, -1"
          "SUPER_CONTROL, right, focusmonitor, +1"
          "SUPER_CONTROL_SHIFT, left, movecurrentworkspacetomonitor, -1"
          "SUPER_CONTROL_SHIFT, right, movecurrentworkspacetomonitor, +1"
        ];

        bind = [
          "SUPER, SUPER_L, exec, ${system-shell} launcher"

          "SUPER, T, exec, uwsm-app ghostty"
          "SUPER, B, exec, uwsm-app zen-beta"

          "SUPER_SHIFT, F, fullscreen, 1"

          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"
          "SUPER, 0, workspace, 10"

          "SUPER_SHIFT, 2, exec, ${hyprshot} -z -m window -m active"
          "SUPER_SHIFT, 3, exec, ${hyprshot} -z -m output -m active"
          "SUPER_SHIFT, 4, exec, ${hyprshot} -z -m region"
          ", Print, exec, ${hyprshot} -z -m window -m active"
          "SUPER, Print, exec, ${hyprshot} -z -m output -m active"
          "SUPER_SHIFT, Print, exec, ${hyprshot} -z -m region"
        ];

        windowrule = [
          "suppressevent maximize, class:.*"

          "nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0"
          "tag +games, initialClass:^(.*)[.]exe$, fullscreenstate:* 2"

          "immediate, fullscreenstate:2"
          "immediate, fullscreenstate:3"
          "syncfullscreen, fullscreen:1"
          "idleinhibit, fullscreen:1"

          "content game, tag:games"
          "tag +games, content:game"

          "opaque, tag:games"
          "immediate, tag:games"
          "idleinhibit fullscreen, tag:games"
          "fullscreenstate:3 3, tag:games, fullscreen:1"
          "float, tag:games, fullscreen:1"

          "float, class:zen-beta,initialTitle:^(Picture-in-Picture)$"
          "pin, class:zen-beta,initialTitle:^(Picture-in-Picture)$"
          "idleinhibit fullscreen,class:zen-beta"

          "float,title:^(Open)$"
          "float,title:^(Choose Files)$"
          "float,title:^(Save As)$"
          "float,title:^(Confirm to replace files)$"
          "float,title:^(File Operation Progress)$"
        ];

        layerrule = [
          "blur, system-shell"
          "ignorezero, system-shell"
          "animation slide, system-shell"
          "abovelock, system-shell"

          "blur, system-bar"
          "xray on, system-bar"
          "ignorezero, system-bar"
          "animation slide, system-bar"
        ];
      };
    };

    home.packages = with pkgs; [ nautilus ];

    xdg.configFile."uwsm/env".source = let
      inherit (config.home) sessionVariables;
      export = k: v: "export ${builtins.toString k}=${builtins.toString v}";
      env = strings.concatLines (attrsets.mapAttrsToList export sessionVariables);
    in pkgs.writeText "env" env;

    services = {
      hyprpolkitagent.enable = true;
      hypridle = {
        enable = true;
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
      wpaperd = {
        enable = true;
        package = pkgs.wpaperd.overrideAttrs (old: {
          cargoBuildFlags = [ "--no-default-features" ];
        });
        settings.default = {
          path = "${config.xdg.userDirs.pictures}/Wallpapers";
          mode = "center";
          duration = "8h";
          sorting = "random";
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

    systemd.user.services = {
      hyprpolkitagent.Service.Slice = "session.slice";
      hypridle.Service.Slice = "session.slice";
      wpaperd.Service.Slice = "session.slice";

      system-shell-notifd = {
        Install.WantedBy = [ "system-shell.service" ];
        Service = {
          ExecStart = "${pkgs.astal.notifd}/bin/astal-notifd -d";
          Restart = "on-failure";
          RestartSec = 5;
          Slice = "background.slice";
        };
        Unit = {
          After = [ config.wayland.systemd.target ];
          PartOf = [ config.wayland.systemd.target ];
        };
      };

      system-shell = {
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          ExecStart = "${system-shell}";
          Restart = "on-failure";
          RestartSec = 10;
          Environment = [ "GSK_RENDERER=ngl" ];
          Slice = "session.slice";
        };
        Unit = {
          After = [ config.wayland.systemd.target ];
          ConditionEnvironment = "WAYLAND_DISPLAY";
          PartOf = [ config.wayland.systemd.target ];
        };
      };
    };
  };
}
