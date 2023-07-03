{ pkgs, hyprland, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) hex;
in {
  imports = [
    hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };

    recommendedEnvironment = true;

    extraConfig = ''
      $wofi = ${pkgs.wofi}/bin/wofi
      $swaync = ${pkgs.swaynotificationcenter}/bin/swaync-client
      $pwmanager = ${pkgs.rofi-rbw}/bin/rofi-rbw
      $terminal = ${pkgs.wezterm}/bin/wezterm
      $volume = ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@
      $mute = ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      $light = ${pkgs.light}/bin/light
      $player = ${pkgs.playerctl}/bin/playerctl
      $pkill = ${pkgs.procps}/bin/pkill

      bind = SUPER, Escape, exec, $terminal
      bind = SUPER, Space, exec, $pkill wofi || $wofi
      bind = SUPER, Return, exec, $swaync -op -sw
      bind = SUPER, Q, killactive

      bind = SUPER, Tab, cyclenext,
      bind = SUPER, Tab, bringactivetotop,

      bind = SUPER, backslash, exec, $pwmanager

      bindel =, XF86AudioRaiseVolume, exec, $volume 5%+
      bindel =, XF86AudioLowerVolume, exec, $volume 5%-
      bindel =, XF86AudioMute, exec, $mute
      bindel =, XF86MonBrightnessDown, exec, $light -U 10
      bindel =, XF86MonBrightnessUp, exec, $light -A 10
      bind =, XF86AudioPlay, exec, $player play-pause
      bind =, XF86AudioPrev, exec, $player previous
      bind =, XF86AudioNext, exec, $player next

      exec-once=xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2

      windowrule = float, title:^(Firefox — Sharing Indicator)$
      windowrule = nofocus, title:^(Firefox — Sharing Indicator)$
      windowrule = move 20 100%-60, title:^(Firefox — Sharing Indicator)$

      layerrule = blur, wofi
      layerrule = ignorezero, wofi

      layerrule = blur, waybar
      layerrule = ignorezero, waybar

      layerrule = blur, swaync-control-center
      layerrule = ignorezero, swaync-control-center

      layerrule = blur, swaync-notification-window
      layerrule = ignorezero, swaync-notification-window

      general {
        gaps_in = 6
        gaps_out = 10
        col.inactive_border = 0xff${hex.gutter}
        col.active_border = 0xff${hex.split}
        no_border_on_floating = true
      }

      decoration {
        rounding = 4

        blur = true
        blur_size = 16
        blur_passes = 3
        blur_ignore_opacity = false
        blur_new_optimizations = true

        drop_shadow = true
        shadow_range = 30
        shadow_ignore_window = true
        shadow_offset = [0, 20]
        shadow_render_power = 2
        col.shadow = 0x14000000
        col.shadow_inactive = 0x201a1a1a
      }

      input {
        kb_options = ctrl:nocaps
        touchpad {
          clickfinger_behavior = true
          tap-to-click = false
          scroll_factor = 0.2
        }
      }

      misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
        mouse_move_enables_dpms = true
        key_press_enables_dpms = true
        vfr = true
      }
    '';
  };
}
