{ config, lib, ... }:

let

  inherit (import ./channels.nix) __nixPath nixPath;
  inherit (lib) mkForce;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;

in

rec {
  nixpkgs = {
    config.allowUnfree = true;
  };

  nix.nixPath = mkForce nixPath;

  _module.args =
    let

      pkgsConf = {
        inherit (config.nixpkgs) localSystem crossSystem;
        config = config.nixpkgs.config // nixpkgs.config;
      };

    in

    rec {
      pkgs = import <nixpkgs> (
        if isLinux then {
          inherit (pkgsConf) config localSystem crossSystem;
        } else {
          inherit (pkgsConf) config;
        }
      );

      pkgs-unstable = import <nixpkgs-unstable> (
        if isLinux then {
          inherit (pkgsConf) config localSystem crossSystem;
        } else {
          inherit (pkgsConf) config;
        }
      );
    };
}
