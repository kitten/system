{
  stdenv,
  astal,
  meson,
  ninja,
  pkg-config,
  gobject-introspection,
  blueprint-compiler,
  gtk4-layer-shell,
  gtk4,
  json-glib,
  networkmanager,
  dart-sass,
  vala,
  wrapGAppsHook4,
  ...
}: let
  astalPackages = [
    astal.astal4
    astal.io
    astal.gjs
    astal.auth
    astal.cava
    astal.apps
    astal.greet
    astal.mpris
    astal.notifd
    astal.network
    astal.battery
    astal.hyprland
    astal.bluetooth
    astal.wireplumber
    astal.powerprofiles
  ];
in stdenv.mkDerivation {
  name = "hyprpanel";
  src = ./.;
  depsBuildBuild = [
    pkg-config
  ];
  nativeBuildInputs = [
    meson
    ninja
    gobject-introspection
    wrapGAppsHook4
    blueprint-compiler
    dart-sass
    vala
  ];
  buildInputs = [
    gtk4
    gtk4-layer-shell
    networkmanager
    json-glib
  ] ++ astalPackages;
}
