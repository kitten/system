{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.rustup
  ];
}
