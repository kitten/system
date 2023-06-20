{ hyprland, ... }:

{
  imports = [
    hyprland.homeManagerModules.default
  ];

  fonts.fontconfig.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
  };

  systemd.user.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # force ozone-based electron apps to use Wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # force Firefox to use Wayland
    "MOZ_WEBRENDER" = "1";
  };
}
