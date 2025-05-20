{ lib, config, pkgs, ... } @ inputs:

with lib;
let
  inherit (import ../../lib/theme.nix inputs) cursorTheme defaultFont iconTheme gtkTheme kvantumTheme;
  cfg = config.modules.desktop;
in {
  options.modules.desktop.theme = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable theming configuration.";
      type = types.bool;
    };
  };

  config = mkIf cfg.theme.enable {
    home.pointerCursor = {
      inherit (cursorTheme) package name;
      gtk.enable = true;
      hyprcursor.enable = true;
      x11.enable = true;
      size = 24;
    };

    home.packages = with pkgs; [
      libsForQt5.qtstyleplugin-kvantum
      libsForQt5.qt5ct
    ];

    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style.name = "kvantum";
    };

    xdg.configFile = {
      "Kvantum/${kvantumTheme.name}".source = "${kvantumTheme.package}/share/Kvantum/${kvantumTheme.name}";
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=${kvantumTheme.name}
      '';
      "qt5ct/qt5ct.conf".text = ''
        [Appearance]
        icon_theme=${iconTheme.name}
      '';
      "qt6ct/qt6ct.conf".text = ''
        [Appearance]
        icon_theme=${iconTheme.name}
      '';
    };

    gtk = {
      enable = true;
      inherit iconTheme;
      theme = gtkTheme;
      font = defaultFont;
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "New York" "Noto Serif" "Noto Color Emoji" ];
        sansSerif = [ "SF Pro Display" "Inter" "Noto Color Emoji" ];
        monospace = [ "Dank Mono" "SF Mono" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
