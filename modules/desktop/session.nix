{ lib, config, pkgs, user, ... } @ inputs:

with lib;
let
  inherit (import ../../lib/theme.nix inputs) cursorTheme defaultFont iconTheme gtkTheme kvantumTheme;
  cfg = config.modules.desktop;
in {
  options.modules.desktop.session = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable session and desktop environment.";
      type = types.bool;
    };
  };

  config = mkIf cfg.session.enable {
    users.users."${user}".extraGroups = [ "video" ];

    boot = {
      plymouth.enable = true;
      initrd.verbose = mkDefault false;
      consoleLogLevel = 0;
    };

    environment.sessionVariables = {
      GSK_RENDERER = mkDefault "ngl";
      QT_QPA_PLATFORM = mkDefault "wayland;xcb";
      GDK_BACKEND = mkDefault "wayland,x11,*";
      SDL_VIDEODRIVER = mkDefault "wayland,x11";
      NIXOS_OZONE_WL = mkDefault "1";
    };

    services = {
      greetd = {
        enable = true;
        settings = {
          terminal.vt = 1;
          default_session.command = let
            hyprConfig = pkgs.writeTextFile {
              name = "hyprland-greeter.conf";
              text = ''
                source=${toString cfg.hyprland.configFile}
                exec-once = ${getExe config.programs.regreet.package}; hyprctl dispatch exit
                animations {
                  enabled = false
                }
              '';
            };
          in escapeShellArgs [
            "${pkgs.dbus}/bin/dbus-run-session"
            "${getExe pkgs.hyprland}"
            "-c" (toString hyprConfig)
          ];
        };
      };
      upower.enable = true;
      gvfs.enable = true;
      logind = {
        powerKey = "suspend";
        powerKeyLongPress = "poweroff";
        lidSwitch = "suspend";
      };
    };

    programs = {
      regreet = {
        enable = true;
        inherit cursorTheme iconTheme;
        font = defaultFont;
        theme = gtkTheme;
        settings.GTK.application_prefer_dark_theme = true;
      };
    };

    security.polkit.enable = true;
  };
}
