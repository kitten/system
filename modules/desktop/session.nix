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
    };

    services.greetd = {
      enable = true;
    };

    programs.regreet = {
      enable = true;
    };

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    security = {
      polkit.enable = true;
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };
  };
}
