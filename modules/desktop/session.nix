{ lib, config, pkgs, user, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.session = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable session and desktop environment.";
      type = types.bool;
    };
  };

  config = mkIf cfg.session.enable {
    boot.plymouth.enable = true;

    services = {
      desktopManager.plasma6.enable = true;
      displayManager = {
        defaultSession = "plasma";
        autoLogin = {
          inherit user;
          enable = true;
        };
        sddm = {
          enable = true;
          enableHidpi = true;
          wayland.enable = true;
        };
      };
    };

    environment.plasma6 = {
      excludePackages = with pkgs.kdePackages; [
        elisa
        gwenview
        oxygen
        oxygen-sounds
        khelpcenter
        konsole
      ];
    };

    security = {
      polkit.enable = true;
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = false;
    };
  };
}
