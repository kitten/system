{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.coreutils
  ];
}
