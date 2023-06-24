{ ... }:

{
  imports = [
    ./hyprland.nix
    ./hyprpaper.nix
    ./kanshi.nix
    ./waybar.nix
    ./mako.nix
    ./wofi.nix
    ./lock.nix
    ./eww
  ];

  fonts.fontconfig.enable = true;
}
