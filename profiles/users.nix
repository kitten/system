{ pkgs, lib, ... }:

let
  inherit (lib) optionalAttrs mkMerge mkIf mkDefault;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;

  home = import ../config/home/default.nix;
in

mkMerge [
  {
    home-manager.users.phil = home;
    users.users.phil.home = mkIf isDarwin "/Users/phil";
  }

  (optionalAttrs isLinux {
    users.users.phil = {
      isNormalUser = true;
      uid = 1000;
      home = "/home/phil";
    };
  })
]
