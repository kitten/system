{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.wezterm
  ];
}
