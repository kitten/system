{ lib, pkgs, ... }:

let
  inherit (lib) optional flatten;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
in {
  environment.systemPackages = [
    pkgs.openssl
  ];

  imports = flatten [
    ./users.nix
    ../config/shell.nix
    ../config/nvim/default.nix
    ../config/nodejs.nix
    ../config/gpg.nix
    ../config/fonts.nix

    (optional isDarwin ./darwin.nix)
  ];
}
