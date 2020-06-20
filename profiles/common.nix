{ lib, ... }:

let
  inherit (lib) optional flatten;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
in {
  imports = flatten [
    ./users.nix
    ../config/shell.nix
    ../config/nvim/default.nix
    ../config/nodejs.nix
    ../config/gpg.nix

    (optional isDarwin ./darwin.nix)
  ];
}
