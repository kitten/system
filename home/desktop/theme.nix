{ pkgs, ... } @ inputs:

{
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
}
