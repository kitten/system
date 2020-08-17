{ pkgs-unstable, ... }:

{
  environment.systemPackages = [
    pkgs-unstable.rustup
  ];
}
