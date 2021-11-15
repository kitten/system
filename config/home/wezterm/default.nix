{ pkgs, ... }:

let
  colors = (import ../../colors.nix);
  wezmux = (pkgs.writeScriptBin "wezmux" (builtins.readFile ../../../assets/wezmux.sh));
in {
  home.packages = [ pkgs.wezterm wezmux ];
  xdg.configFile."wezterm/wezterm.lua".text = ''
    local zsh_bin = "${pkgs.zsh}/bin/zsh";
    local colors = ${colors.lua};
  '' + (builtins.readFile ./init.lua);
}
