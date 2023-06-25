{ lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.zsh ];

  environment.pathsToLink = [ "/share/zsh" ];
  environment.variables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

  programs.zsh = {
    enable = true;
    promptInit = lib.mkDefault "";
  };
}
