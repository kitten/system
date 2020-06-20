{ lib, pkgs, ... }:

let
  inherit (lib) optionalAttrs mkMerge;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
in {
  environment.systemPackages = [
    pkgs.gnupg
  ];

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
