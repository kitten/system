{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.kitty
  ];
}
