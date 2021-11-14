{ pkgs, ... }:

let
  colors = (import ../../colors.nix);
in {
  home.packages = [ pkgs.wezterm ];
  xdg.configFile."wezterm/wezterm.lua".text = ''
    local zsh_bin = "${pkgs.zsh}/bin/zsh";
    local colors = ${colors.lua};
  '' + (builtins.readFile ./init.lua);
}
