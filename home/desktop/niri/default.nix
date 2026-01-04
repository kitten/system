{ lib, config, pkgs, ... } @ inputs:

with lib;
let
  inherit (import ./settings.nix inputs) niri-type niri-render;
  kdl = import ./kdl.nix inputs;
  cfg = config.modules.desktop;

  validate-niri-config = config:
    pkgs.runCommand "config.kdl"
      {
        inherit config;
        passAsFile = [ "config" ];
        buildInputs = [ cfg.niri.package ];
      }
      ''
        niri validate -c $configPath
        cp $configPath $out
      '';
in {
  options.modules.desktop.niri = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable Niri configuration.";
      type = types.bool;
    };

    package = mkOption {
      type = types.package;
      default = pkgs.niri;
      description = "The niri package to use.";
    };

    settings = mkOption {
      type = types.nullOr niri-type;
      default = null;
    };
  };

  config = mkIf cfg.niri.enable {
    modules.desktop.niri.settings = {
      prefer-no-csd = mkDefault true;

      input = {
        warp-mouse-to-focus.enable = mkDefault true;
        mouse = {
          accel-speed = mkDefault 0.0;
          accel-profile = mkDefault "flat";
        };
      };

      cursor.hide-after-inactive-ms = mkDefault 2000;
      hotkey-overlay.hide-not-bound = mkDefault true;

      layout = {
        gaps = mkDefault 16;
        center-focused-column = mkDefault "never";
        focus-ring.width = mkDefault 2;
      };

      window-rules = [
        {
          matches = [{ title = "^Picture-in-Picture$"; }];
          open-floating = true;
        }
        {
          matches = [
            { is-urgent = true; }
            { is-floating = true; }
          ];
          open-focused = true;
        }
        {
          geometry-corner-radius = {
            top-left = 9.0;
            top-right = 9.0;
            bottom-left = 9.0;
            bottom-right = 9.0;
          };
          clip-to-geometry = true;
        }
      ];

      binds = let
        wpctl = "${getBin pkgs.wireplumber}/bin/wpctl";
        brightnessctl = "${getBin pkgs.brightnessctl}/bin/brightnessctl";
        playerctl = "${getBin config.services.playerctld.package}/bin/playerctl";
      in {
        "Mod+T".action.spawn = "ghostty";
        "Mod+Space".action.spawn = "cosmic-launcher";
        "Mod+Shift+Space".action.spawn = "cosmic-app-library";

        "Mod+Escape" = {
          repeat = false;
          action.toggle-keyboard-shortcuts-inhibit = {};
        };

        "Mod+O" = {
          repeat = false;
          action.toggle-overview = {};
        };

        "Mod+W" = {
          repeat = false;
          action.close-window = {};
        };

        "Mod+F".action.maximize-column = {};
        "Mod+Shift+F".action.fullscreen-window = {};
        "Mod+Z".action.center-column = {};

        "Mod+Minus".action.set-column-width = [ "-10%" ];
        "Mod+Equal".action.set-column-width = [ "+10%" ];

        "Mod+Left".action.focus-column-left = {};
        "Mod+Down".action.focus-window-down = {};
        "Mod+Up".action.focus-window-up = {};
        "Mod+Right".action.focus-column-right = {};
        "Mod+H".action.focus-column-left = {};
        "Mod+J".action.focus-window-or-workspace-down = {};
        "Mod+K".action.focus-window-or-workspace-up = {};
        "Mod+L".action.focus-column-right = {};

        "Mod+Ctrl+Left".action.move-column-left = {};
        "Mod+Ctrl+Down".action.move-window-down = {};
        "Mod+Ctrl+Up".action.move-window-up = {};
        "Mod+Ctrl+Right".action.move-column-right = {};
        "Mod+Ctrl+H".action.move-column-left = {};
        "Mod+Ctrl+J".action.move-window-down-or-to-workspace-down = {};
        "Mod+Ctrl+K".action.move-window-up-or-to-workspace-up = {};
        "Mod+Ctrl+L".action.move-column-right = {};

        "Mod+Shift+Left".action.focus-monitor-left = {};
        "Mod+Shift+Down".action.focus-monitor-down = {};
        "Mod+Shift+Up".action.focus-monitor-up = {};
        "Mod+Shift+Right".action.focus-monitor-right = {};
        "Mod+Shift+H".action.focus-monitor-left = {};
        "Mod+Shift+J".action.focus-monitor-down = {};
        "Mod+Shift+K".action.focus-monitor-up = {};
        "Mod+Shift+L".action.focus-monitor-right = {};

        "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = {};
        "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = {};
        "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = {};
        "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = {};
        "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = {};
        "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = {};
        "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = {};
        "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = {};

        "Mod+Page_Down".action.focus-workspace-down = {};
        "Mod+Page_Up".action.focus-workspace-up = {};
        "Mod+U".action.focus-workspace-down = {};
        "Mod+I".action.focus-workspace-up = {};
        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = {};
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = {};
        "Mod+Ctrl+U".action.move-column-to-workspace-down = {};
        "Mod+Ctrl+I".action.move-column-to-workspace-up = {};

        "Mod+Shift+Page_Down".action.move-workspace-down = {};
        "Mod+Shift+Page_Up".action.move-workspace-up = {};
        "Mod+Shift+U".action.move-workspace-down = {};
        "Mod+Shift+I".action.move-workspace-up = {};

        "Mod+WheelScrollDown".action.focus-column-right = {};
        "Mod+WheelScrollUp".action.focus-column-left = {};

        "Mod+BracketLeft".action.consume-or-expel-window-left = {};
        "Mod+BracketRight".action.consume-or-expel-window-right = {};
        "Mod+Comma".action.consume-window-into-column = {};
        "Mod+Period".action.expel-window-from-column = {};

        "Print".action.screenshot = {};
        "Ctrl+Print".action.screenshot-screen = {};
        "Alt+Print".action.screenshot-window = {};

        "XF86AudioRaiseVolume".action.spawn = map escapeShellArg [ wpctl "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "3%+" ];
        "XF86AudioLowerVolume".action.spawn = map escapeShellArg [ wpctl "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "3%-" ];
        "XF86AudioMute".action.spawn = map escapeShellArg [ wpctl "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
        "XF86AudioMicMute".action.spawn = map escapeShellArg [ wpctl "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
        "XF86MonBrightnessDown".action.spawn = map escapeShellArg [ brightnessctl "set" "3%-" ];
        "XF86MonBrightnessUp".action.spawn = map escapeShellArg [ brightnessctl "set" "+3%" ];
        "XF86AudioPlay".action.spawn = map escapeShellArg [ playerctl "play-pause" ];
        "XF86AudioPause".action.spawn = map escapeShellArg [ playerctl "pause" ];
        "XF86AudioNext".action.spawn = map escapeShellArg [ playerctl "next" ];
        "XF86AudioPrev".action.spawn = map escapeShellArg [ playerctl "previous" ];
      };
    };

    services.playerctld.enable = mkDefault true;

    xdg.configFile.niri-config = {
      target = "niri/config.kdl";
      source = validate-niri-config (kdl.serialize.nodes (niri-render cfg.niri.settings));
    };

    systemd.user.sessionVariables = {
      XCURSOR_THEME = "Cosmic";
      GTK_THEME = "Adwaita:dark";
      QT_STYLE_OVERRIDE = "adwaita-dark";
    };
  };
}
