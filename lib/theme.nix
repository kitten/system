{ pkgs, ... }:

{
  cursorTheme = {
    name = "macOS";
    package = pkgs.apple-cursor;
  };
  defaultFont = {
    name = "SF Pro Display";
    package = pkgs.sf-pro;
    size = 11;
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
}
