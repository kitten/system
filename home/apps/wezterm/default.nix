{ lib, config, pkgs, helpers, ... } @ inputs:

with lib;
let
  inherit (import ../../../lib/colors.nix inputs) colors mkLuaSyntax;
  inherit (pkgs) wezterm;

  cfg = config.modules.apps;

  configStr = ''
    local font_size = ${if helpers.isDarwin then "14" else "12"};
    local is_linux = ${if helpers.isLinux then "true" else "false"};
    local zsh_bin = "${pkgs.zsh}/bin/zsh";
    local colors = ${mkLuaSyntax colors};
  '' + (builtins.readFile ./init.lua);

  shellIntegrationStr = ''
    source "${wezterm}/etc/profile.d/wezterm.sh"
  '';
in {
  options.modules.apps.wezterm = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Wezterm.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.wezterm.enable) {
    home.packages = [ wezterm ];
    xdg.configFile."wezterm/wezterm.lua".text = configStr;
    programs.zsh.initExtra = shellIntegrationStr;
  };
}
