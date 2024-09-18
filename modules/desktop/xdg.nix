{ lib, config, user, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop.xdg = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable services.";
      type = types.bool;
    };
  };

  config = mkIf cfg.xdg.enable {
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
  };
}
