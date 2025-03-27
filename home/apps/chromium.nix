{ lib, config, pkgs, helpers, ... }:

with lib;
let
  cfg = config.modules.apps;
in {
  options.modules.apps.chromium = {
    enable = mkOption {
      default = false;
      description = "Whether to enable (Ungoogled) Chromium.";
      type = types.bool;
    };
  };

  config.modules.apps.chromium = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
  config = mkIf (cfg.enable && cfg.chromium.enable) {
    home.packages = with pkgs; [
      ungoogled-chromium
    ];

    systemd.user.sessionVariables.NIXOS_OZONE_WL = mkDefault 1;
  };
}
