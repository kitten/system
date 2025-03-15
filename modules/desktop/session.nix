{ lib, config, pkgs, ... }:

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
    boot = {
      plymouth.enable = true;
      initrd.verbose = mkDefault false;
      consoleLogLevel = 0;
      kernelParams = [ "console=tty1" "vt.global_cursor_default=0" ];
    };

    services = {
      desktopManager.plasma6.enable = true;
      displayManager = {
        defaultSession = "plasma";
        sddm = {
          enable = true;
          enableHidpi = true;
          wayland.enable = true;
        };
      };
    };

    environment = {
      systemPackages = with pkgs.kdePackages; [
        sddm-kcm
        qtmultimedia
        pkgs.apple-cursor
      ];
      plasma6 = {
        excludePackages = with pkgs.kdePackages; [
          discover
          ffmpegthumbs
          plasma-browser-integration
          kate
          konsole
          krdp
          elisa
          gwenview
          oxygen
          oxygen-sounds
          khelpcenter
        ];
      };
    };

    security = {
      polkit.enable = true;
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
      ];
    };
  };
}
