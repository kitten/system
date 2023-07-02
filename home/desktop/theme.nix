{ pkgs, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) hex;
  inherit (pkgs) hyprland swayidle;
  swaylock = pkgs.swaylock-effects;
in {
  services.xsettingsd = {
    enable = true;
    settings = {
      "Gtk/CursorThemeName" = "Bibata-Modern-Classic";
      "Net/IconThemeName" = "WhiteSur-dark";
      "Xft/Antialias" = true;
      "Xft/Hinting" = true;
      "Xft/HintStyle" = "hintslight";
      "Xft/RGBA" = "rgb";
      "Xft/dpi" = 163;
    };
  };

  fonts.fontconfig.enable = true;

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;

    font = {
      package = pkgs.inter;
      name = "Inter";
      size = 10;
    };

    iconTheme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme.override {
        alternativeIcons = true;
        boldPanelIcons = true;
      };
    };

    theme = {
      name = "WhiteSur-Dark";
      package = pkgs.whitesur-gtk-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  systemd.user.sessionVariables = {
    GTK_THEME = "WhiteSur-Dark";
  };
}
