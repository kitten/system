{ lib, pkgs, ... }:

let
  inherit (lib) mkMerge mkForce optionalAttrs;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
  inherit (import ../nix/channels.nix) nixPath;
  inherit (import ../nix/secrets.nix) readSecretFileContents;
in

mkMerge [
  {
    environment.systemPackages = with pkgs; [
      zsh
    ];

    environment.pathsToLink = [ "/share/zsh" ];

    environment.variables = {
      GITHUB_TOKEN = readSecretFileContents ../assets/github-token;
      NIX_PATH = mkForce nixPath;
      SHELL = "${pkgs.zsh}/bin/zsh";
    };

    programs.zsh = {
      enable = true;
      promptInit = lib.mkDefault "";
    };
  }

  (optionalAttrs isDarwin {
    environment.shells = [ pkgs.zsh ];
  })

  (optionalAttrs isLinux {
    users.defaultUserShell = pkgs.zsh;
  })
]
