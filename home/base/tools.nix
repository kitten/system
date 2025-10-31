{ lib, pkgs, ... }:

with lib;
let
  rgExcludesFile = pkgs.writeTextFile {
    name = ".rgignore";
    text = ''
      *~
      *.map
    '';
  };
in
{
  home = {
    packages = with pkgs; [
      ripgrep
      xh
      sd
      fd
      jq
    ];
    shellAliases = {
      http = "xh";
    };
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--ignore-file=${rgExcludesFile}"
      "--smart-case"
    ];
  };
}
