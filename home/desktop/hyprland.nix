{ pkgs, hyprland, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) hex;
in {
  imports = [
    hyprland.homeManagerModules.default
  ];

  services.playerctld.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };

    recommendedEnvironment = true;

    extraConfig = ''
      $volume_set = ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@
      $mute_set = ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@
      $light_up = ${pkgs.light}/bin/light -A 10
      $light_down = ${pkgs.light}/bin/light -U 10
      $player = ${pkgs.playerctl}/bin/playerctl

      bind = SUPER, Return, exec, wezterm
      bind = SUPER, Space, exec, wofi
      bind = SUPER, Q, killactive

      binde =, XF86AudioRaiseVolume, exec, $volume_set 5%+
      binde =, XF86AudioLowerVolume, exec, $volume_set 5%-
      binde =, XF86AudioMute, exec, $mute_set toggle
      binde =, XF86MonBrightnessDown, exec, $light_down
      binde =, XF86MonBrightnessUp, exec, $light_up
      bind =, XF86AudioPlay, exec, $player play-pause
      bind =, XF86AudioPrev, exec, $player previous
      bind =, XF86AudioNext, exec, $player next

      exec-once=xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
      env = GDK_SCALE, 2
      env = XCURSOR_SIZE, 32

      layerrule = blur, waybar
      layerrule = ignorezero, waybar

      general {
        gaps_in = 6
        gaps_out = 10
        col.inactive_border = 0xff${hex.gutter}
        col.active_border = 0xff${hex.split}
      }

      decoration {
        rounding = 4

        blur = true
        blur_size = 32
        blur_passes = 1
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
    '';
  };
}
