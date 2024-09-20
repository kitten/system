{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.theme = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable default theme.";
      type = types.bool;
    };
  };

  config = mkIf cfg.theme.enable {
    fonts.fontconfig.enable = true;

    services.xsettingsd = {
      enable = true;
      settings = {
        "Gtk/CursorThemeName" = "Bibata-Modern-Classic";
        "Xft/Antialias" = true;
        "Xft/Hinting" = true;
        "Xft/HintStyle" = "hintslight";
        "Xft/RGBA" = "rgb";
        "Xft/dpi" = 163;
      };
    };

    home.pointerCursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
