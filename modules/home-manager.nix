{ lib, ... }:

let
  inherit (lib) optional flatten;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
  inherit (import ../nix/channels.nix) __nixPath nixPath;
in {
  imports = flatten [
    (optional isDarwin <home-manager/nix-darwin>)
    (optional isLinux <home-manager/nixos>)
  ];
}
