{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.desktop;

  corePackages = with pkgs; [
    niri
    config.services.displayManager.cosmic-greeter.package
    cosmic-applets
    cosmic-applibrary
    cosmic-bg
    cosmic-comp
    cosmic-files
    cosmic-idle
    cosmic-initial-setup
    cosmic-launcher
    cosmic-notifications
    cosmic-osd
    cosmic-panel
    cosmic-session
    cosmic-settings
    cosmic-settings-daemon
    cosmic-workspaces-epoch
  ];

  optionalPackages = with pkgs; [
    xwayland-satellite
    xdg-user-dirs
    cosmic-icons
    cosmic-screenshot
    cosmic-wallpapers
  ];

  cosmic-configs = {
    "com.system76.CosmicComp/v1/workspaces" = ''
      (
        workspace_mode: OutputBound,
        workspace_layout: Horizontal,
      )
    '';
    "com.system76.CosmicComp/v1/autotile_behavior" = ''
      PerWorkspace
    '';
    "com.system76.CosmicPanel/v1/entries" = ''
      [
        "Panel",
      ]
    '';
    "com.system76.CosmicTk/v1/interface_font" = let
      defaultFont = head config.fonts.fontconfig.defaultFonts.sansSerif;
    in ''
      (
          family: "${defaultFont}",
          weight: Normal,
          stretch: Normal,
          style: Normal,
      )
    '';
    "com.system76.CosmicTk/v1/monospace_font" = let
      defaultFont = head config.fonts.fontconfig.defaultFonts.monospace;
    in ''
      (
          family: "${defaultFont}",
          weight: Normal,
          stretch: Normal,
          style: Normal,
      )
    '';
  };

  cosmic-base-config = let
    fileDrvs =
      attrsets.mapAttrsToList
        (name: text: pkgs.writeTextDir "share/cosmic/${name}" text)
        cosmic-configs;
  in pkgs.buildEnv {
    name = "cosmic-base-config";
    paths = fileDrvs;
    pathsToLink = [ "/share/cosmic" ];
  };

  cosmic-ext-niri-desktop = let
    startCosmicExtNiri = pkgs.writeShellApplication {
      name = "start-cosmic-ext-niri";
      runtimeInputs = with pkgs; [ systemd coreutils ];
      text = with pkgs; let
        cleanupCosmicConfigs =
          concatMapAttrsStringSep "\n"
            (name: _value: ''rm -f "$XDG_CONFIG_HOME/cosmic/${name}"'')
            cosmic-configs;
      in /*sh*/''
        set -e

        if systemctl --user -q is-active cosmic-niri-session.service; then
          exit 1
        fi

        for unit in $(systemctl --user --no-legend --state=failed --plain list-units | cut -f1 -d' '); do
          partof="$(systemctl --user show -p PartOf --value "$unit")"
          for target in cosmic-session.target graphical-session.target; do
            if [ "$partof" = "$target" ]; then
              systemctl --user reset-failed "$unit"
              break
            fi
          done
        done

        XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
        touch "$XDG_CONFIG_HOME/cosmic-initial-setup-done"
        ${cleanupCosmicConfigs}

        export XDG_CURRENT_DESKTOP="''${XDG_CURRENT_DESKTOP:=niri}"
        export XDG_SESSION_TYPE="''${XDG_SESSION_TYPE:=wayland}"
        export DCONF_PROFILE=cosmic

        systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP DCONF_PROFILE
        systemctl --user --wait start cosmic-niri-session.service

        systemctl --user start --job-mode=replace-irreversibly niri-shutdown.target
        systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET
      '';
    };
  in (pkgs.writeTextFile {
    name = "cosmic-on-niri";
    destination = "/share/wayland-sessions/COSMIC-on-niri.desktop";
    text = ''
      [Desktop Entry]
      Name=COSMIC-on-niri
      Comment=This session logs you into the COSMIC desktop on niri
      Type=Application
      DesktopNames=niri
      Exec=${getExe startCosmicExtNiri}
    '';
  }).overrideAttrs (old: {
    passthru.providedSessions = [ "COSMIC-on-niri" ];
  });

  cosmic-ext-alternative-startup = pkgs.rustPlatform.buildRustPackage rec {
    pname = "cosmic-ext-alternative-startup";
    version = "unstable-2024-11-24";
    src = pkgs.fetchFromGitHub {
      owner = "drakulix";
      repo = pname;
      rev = "8ceda00197c7ec0905cf1dccdc2d67d738e45417";
      hash = "sha256-0kqn3hZ58uQMl39XXF94yQS1EWmGIK45/JFTAigg/3M=";
    };
    cargoHash = "sha256-DeMkAG2iINGden0Up013M9mWDN4QHrF+FXoNqpGB+mg=";
    meta.mainProgram = pname;
  };
in {
  options.modules.desktop.niri-cosmic = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable COSMIC on Niri";
      type = types.bool;
    };
  };

  config = mkIf cfg.niri-cosmic.enable {
    boot = {
      plymouth.enable = true;
      initrd.verbose = mkDefault false;
      consoleLogLevel = 0;
    };

    programs = {
      dconf = {
        enable = true;
        packages = [ pkgs.cosmic-session ];
      };
    };

    environment = {
      pathsToLink = [
        "/share/backgrounds"
        "/share/cosmic"
        "/share/cosmic-layouts"
        "/share/cosmic-themes"
      ];
      systemPackages = corePackages ++ optionalPackages ++ [
        cosmic-base-config
      ];
      sessionVariables = {
        X11_BASE_RULES_XML = "${config.services.xserver.xkb.dir}/rules/base.xml";
        X11_EXTRA_RULES_XML = "${config.services.xserver.xkb.dir}/rules/base.extras.xml";

        GSK_RENDERER = mkDefault "ngl";
        QT_QPA_PLATFORM = mkDefault "wayland;xcb";
        GDK_BACKEND = mkDefault "wayland,x11,*";
        SDL_VIDEODRIVER = mkDefault "wayland,x11";
        NIXOS_OZONE_WL = mkDefault 1;
        COSMIC_DATA_CONTROL_ENABLED = mkDefault 1;
      };
    };

    hardware.system76.power-daemon.enable = mkDefault true;

    services = {
      graphical-desktop.enable = true;
      displayManager = {
        cosmic-greeter.enable = true;
        sessionPackages = [ cosmic-ext-niri-desktop ];
      };

      dbus = {
        enable = true;
        implementation = mkDefault "broker";
      };

      accounts-daemon.enable = true;
      libinput.enable = true;
      upower.enable = true;

      acpid.enable = mkDefault true;
      gnome.gnome-keyring.enable = mkDefault true;
      gvfs.enable = mkDefault true;

      logind.settings.Login = {
        powerKey = "suspend";
        powerKeyLongPress = "poweroff";
        lidSwitch = "suspend";
      };

      geoclue2 = {
        enable = true;
        enableDemoAgent = false;
        whitelistedAgents = [ "geoclue-demo-agent" ];
      };
    };

    security = {
      polkit.enable = true;
      rtkit.enable = true;
      pam.services.cosmic-greeter = { };
    };

    systemd = {
      packages = with pkgs; [ cosmic-session niri ];
      user.services = {
        cosmic-niri-session = let
          set-environment = config.system.build.setEnvironment;
          init-session = pkgs.writeShellScriptBin "init-cosmic-niri-session" /*sh*/ ''
            XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
            NIRI_CONFIG="''${NIRI_CONFIG:-$XDG_CONFIG_HOME/niri/config.kdl}"
            printf "%s\n" \
              "spawn-at-startup \"${getExe cosmic-ext-alternative-startup}\"" \
              "include \"$NIRI_CONFIG\"" \
              > "$RUNTIME_DIRECTORY/.niri-config.kdl"
          '';
          run-session = pkgs.writeShellScriptBin "run-cosmic-niri-session" /*sh*/''
            source ${set-environment}
            ${getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
            export NIRI_CONFIG="$RUNTIME_DIRECTORY/.niri-config.kdl"
            exec ${getBin pkgs.cosmic-session}/bin/cosmic-session ${getBin pkgs.niri}/bin/niri --session
          '';
        in {
          bindsTo = [ "graphical-session.target" ];
          serviceConfig = {
            RuntimeDirectory = "cosmic-niri-session";
            RuntimeDirectoryMode = "0700";
            Type = "notify";
            NotifyAccess = "all";
            Slice = "session.slice";
            Restart = "on-failure";
            ExecStartPre = getExe init-session;
            ExecStart = getExe run-session;
          };
        };
      };
    };

    xdg = {
      sounds.enable = true;
      icons.fallbackCursorThemes = mkDefault [ "Cosmic" ];
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        config.niri = {
          default = [ "gnome" "gtk" ];
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          "org.freedesktop.impl.portal.Screenshot" = "gnome";
        };
      };
    };

    fonts.packages = with pkgs; [
      fira
      noto-fonts
      open-sans
    ];
  };
}
