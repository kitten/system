{ pkgs-unstable, ... }:

{
  environment.systemPackages = [
    pkgs-unstable.kitty
  ];
}
