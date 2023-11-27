{ pkgs, helpers, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) colors mkLuaSyntax;

  pkg = pkgs.wezterm;

  configStr = ''
    local font_size = ${if helpers.isDarwin then "14" else "12"};
    local is_linux = ${if helpers.isLinux then "true" else "false"};
    local zsh_bin = "${pkgs.zsh}/bin/zsh";
    local colors = ${mkLuaSyntax colors};
  '' + (builtins.readFile ./init.lua);

  shellIntegrationStr = ''
    source "${pkg}/etc/profile.d/wezterm.sh"
  '';
in {
  home.packages = [pkg];
  xdg.configFile."wezterm/wezterm.lua".text = configStr;
  programs.zsh.initExtra = shellIntegrationStr;
}
