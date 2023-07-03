{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnome.gnome-calendar
    gnome.nautilus
    gnome.sushi
  ];
}
