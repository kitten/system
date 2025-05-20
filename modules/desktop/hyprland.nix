{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.modules.desktop;

  mkConfig = input: monitor: pkgs.writeText "hyprland.conf" ''
    debug {
      error_position=1
    }

    general {
      allow_tearing=true
    }

    input {
      touchpad {
        clickfinger_behavior=true
        scroll_factor=0.180000
        tap-and-drag=false
        tap-to-click=false
      }
      kb_options=ctrl:nocaps,lv3:ralt_switch
      kb_layout=${cfg.hyprland.input.kb_layout}
      kb_model=${cfg.hyprland.input.kb_model}
      kb_variant=${cfg.hyprland.input.kb_variant}
      sensitivity=${toString cfg.hyprland.input.sensitivity}
    }

    misc {
      disable_hyprland_logo=true
      disable_splash_rendering=true
      vrr=1
    }

    render {
      direct_scanout=1
      expand_undersized_textures=false
    }

    cursor {
      sync_gsettings_theme=false
    }

    ecosystem {
      no_update_news = true
      no_donation_nag = true
    }

    ${concatMapStringsSep "\n" (x: "monitor=${x}") cfg.hyprland.monitor}
    monitor=, preferred, auto, 1
  '';
in {
  options.modules.desktop.hyprland = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable Hyprland";
      type = types.bool;
    };

    input = mkOption {
      default = { };
      type = types.submodule {
        options = {
          sensitivity = mkOption {
            default = 0.0;
            type = types.float;
          };
          kb_model = mkOption {
            default = "apple";
            type = types.str;
          };
          kb_variant = mkOption {
            default = "mac";
            type = types.str;
          };
          kb_layout = mkOption {
            default = "gb";
            type = types.str;
          };
        };
      };
    };

    monitor = mkOption {
      description = "Monitor configuration";
      default = [ ];
      type = lib.types.listOf lib.types.str;
    };

    configFile = mkOption {
      default = mkConfig cfg.hyprland.input cfg.hyprland.monitor;
    };
  };

  config = mkIf cfg.hyprland.enable {
    programs = {
      hyprlock.enable = true;
      hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };
    };

    security.pam.services.hyprlock = {};

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    environment.etc."hypr/hyprland.conf".source = cfg.hyprland.configFile;
  };
}
