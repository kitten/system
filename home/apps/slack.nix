{ lib, config, helpers, pkgs, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.slack = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Slack.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.slack.enable) (mkMerge [
    {
      home.packages = with pkgs; let
        pkg = if helpers.system == "aarch64-linux" then slacky else slack;
      in [ pkg ];
    }

    (helpers.mkIfLinux {
      systemd.user.sessionVariables.NIXOS_OZONE_WL = mkDefault 1;
    })
  ]);
}
