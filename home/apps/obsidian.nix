{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.obsidian = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Obsidian.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.obsidian.enable) {
    home.packages = [pkgs.obsidian];
    systemd.user.sessionVariables.NIXOS_OZONE_WL = mkDefault 1;
  };
}
