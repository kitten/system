{ lib, config, helpers, pkgs, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.discord = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Discord.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.discord.enable) (mkMerge [
    {
      home.packages = with pkgs; [ vesktop ];
    }

    (helpers.mkIfLinux {
      systemd.user.sessionVariables.NIXOS_OZONE_WL = mkDefault 1;
    })
  ]);
}
