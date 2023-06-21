{ pkgs, hyprland, ... }:

{
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
