{ lib, pkgs, ... }:

let
  inherit (lib) mkMerge optionalAttrs;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
in

mkMerge [
  {
    environment.systemPackages = [ pkgs.zsh ];
    environment.pathsToLink = [ "/share/zsh" ];

    programs.zsh = {
      enable = true;
      promptInit = lib.mkDefault "";
    };
  }

  (optionalAttrs isDarwin {
    environment.shells = [ pkgs.zsh ];
    environment.loginShell = pkgs.zsh;
  })

  (optionalAttrs isLinux {
    users.defaultUserShell = pkgs.zsh;
  })
]
