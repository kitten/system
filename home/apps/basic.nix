{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnome.nautilus
    gnome.sushi
  ];
}
