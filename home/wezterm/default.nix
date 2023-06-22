{ pkgs, helpers, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) colors mkLuaSyntax;
in {
  home.packages = [ pkgs.wezterm ];

  xdg.configFile."wezterm/wezterm.lua".text = ''
    local font_size = ${if helpers.isDarwin then "14" else "12"};
    local zsh_bin = "${pkgs.zsh}/bin/zsh";
    local colors = ${mkLuaSyntax colors};
  '' + (builtins.readFile ./init.lua);
}
