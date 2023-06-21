{ ... }:

{
  imports = [
    ./hyprland.nix
    ./kanshi.nix
    ./waybar.nix
    ./mako.nix
    ./wofi.nix
  ];

  fonts.fontconfig.enable = true;
}
