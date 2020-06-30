{ lib, ... }:

let
  inherit (lib) optional flatten;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
in {
  imports = flatten [
    ./home-manager.nix
    ./dnscrypt.nix
    (optional isDarwin ./darwin.nix)
  ];
}
