{ lib, pkgs, ... }:

let
  inherit (lib) mkMerge optionalAttrs;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
  inherit (import ../nix/secrets.nix) readSecretFileContents;
in

mkMerge [
  {
    environment.systemPackages = with pkgs; [
      zsh
      ripgrep
      curl
      sd
    ];

    environment.pathsToLink = [ "/share/zsh" ];

    environment.variables = {
      GITHUB_TOKEN = readSecretFileContents ../assets/github-token;
    };

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
