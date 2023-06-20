{ ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./mako.nix
    ./wofi.nix
  ];

  fonts.fontconfig.enable = true;
}
