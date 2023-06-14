{ pkgs, config, lib, ... }:

let
  inherit (lib) optionalAttrs mkMerge mkIf mkDefault;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
in

mkMerge [
  {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.phil = _: {
        manual.manpages.enable = false;
        home.stateVersion = "22.11";
        xdg.enable = true;
        imports = [ ../config/home/default.nix ];
      };
    };

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
