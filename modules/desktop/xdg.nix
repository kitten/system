{ lib, user, ... }:

{
  home-manager.users.${user} = { ... }: {
    systemd.user.sessionVariables = {
      "NIXOS_OZONE_WL" = lib.mkDefault "1";
      "MOZ_ENABLE_WAYLAND" = lib.mkDefault "1";
      "QT_WAYLAND_DISABLE_WINDOWDECORATIONS" = lib.mkDefault "1";
      "QT_WAYLAND_FORCE_DPI" = lib.mkDefault "physical";
      "QT_QPA_PLATFORM" = lib.mkDefault "wayland-egl";
    };

    xdg = {
      mimeApps = {
        enable = true;
      };
      userDirs = {
        enable = true;
        createDirectories = true;
      };
      systemDirs.data = [
        "/usr/share"
        "/var/lib/flatpak/exports/share"
        "$HOME/.local/share/flatpak/exports/share"
      ];
    };
  };
}
