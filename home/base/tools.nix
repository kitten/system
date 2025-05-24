{ lib, pkgs, ... }:

with lib;
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
}
