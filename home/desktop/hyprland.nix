{ hyprland, ... }:

{
  imports = [
    hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    extraConfig = ''
      bind = SUPER, Return, exec, wezterm
      bind = SUPER, Space, exec, wofi
      bind = SUPER, Q, killactive

      exec-once=xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 1.44
      env = GDK_SCALE, 2
      env = XCURSOR_SIZE, 32
    '';
  };
}
