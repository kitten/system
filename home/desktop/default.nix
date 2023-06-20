{ ... }:

{
  imports = [
    ./hyprland.nix
    ./mako.nix
    ./wofi.nix
  ];

  fonts.fontconfig.enable = true;
}
