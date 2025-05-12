{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;

  cursorTheme = {
    name = "macOS";
    package = pkgs.apple-cursor;
  };

  iconTheme = {
    name = "WhiteSur";
    package = pkgs.whitesur-icon-theme.override {
      boldPanelIcons = true;
      alternativeIcons = true;
    };
  };

  gtkTheme = {
    name = "WhiteSur-Dark-solid";
    package = pkgs.whitesur-gtk-theme;
  };

  kvantumTheme = rec {
    name = "WhiteSur-opaqueDark";
    package = pkgs.stdenv.mkDerivation {
      pname = "whitesur-kde";
      version = pkgs.whitesur-kde.version;
      src = pkgs.whitesur-kde.src;
      installPhase = /*sh*/''
        mkdir -p "$out/share/Kvantum/${name}"
        cp -R Kvantum/**/* "$out/share/Kvantum/${name}"
      '';
    };
  };
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
      catppuccin-kvantum
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
      font = {
        name = "SF Pro Display";
        package = pkgs.sf-pro;
        size = 11;
      };
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
        serif = [ "Noto Serif" "Noto Color Emoji" ];
        sansSerif = [ "Inter" "Noto Color Emoji" ];
        monospace = [ "Dank Mono" "Roboto Mono" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
