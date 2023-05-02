{ lib, pkgs, ... }:

let
  inherit (lib) optional flatten;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
in {
  environment.systemPackages = [
    pkgs.openssl
  ];

  imports = flatten [
    ../config/dns.nix
    ../config/shell.nix
    ../config/nvim/default.nix
    ../config/nodejs.nix
    ../config/rust.nix
    ../config/gpg.nix
    ../config/fonts.nix
    ../config/term.nix
    ../config/postgres.nix
    ../config/mysql.nix

    ./tools.nix
    ./users.nix

    (optional isDarwin ./darwin.nix)
  ];
}
