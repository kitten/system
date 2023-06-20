{ hyprland, ... }:

{
  imports = [
    hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      bind = SUPER, Return, exec, wezterm
      bind = SUPER, Space, exec, wofi
      bind = SUPER, Q, killactive
    '';
  };
}
