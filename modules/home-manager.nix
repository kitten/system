{ lib, ... }:

let
  inherit (lib) optional flatten;
  inherit (import ../nix/channels.nix) __nixPath;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
in {
  imports = flatten [
    (optional isDarwin <home-manager/nix-darwin>)
    (optional isLinux <home-manager/nixos>)
  ];
}
