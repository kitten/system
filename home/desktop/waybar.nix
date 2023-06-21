{ pkgs, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) colors shell;
in {
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "bottom";
        passthrough = false;
        fixed-center = true;
        spacing = 12;

        modules-left = [ "custom/wofi" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "network" "wireplumber" "battery" ];

        "custom/wofi" = {
          format = "Search";
          on-click = "${pkgs.wofi}/bin/wofi";
          tooltip = false;
        };

        clock = {
          interval = 60;
          format = "{:%a %b %d %H:%M}";
          tooltip = false;
        };

        battery = {
          interval = 60;
          full-at = 100;
          states = {
            good = 90;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-full = " 100%";
          format-icons = [ "" "" "" "" "" ];
          tooltip = false;
        };

        wireplumber = {
          format = "{icon}";
          format-icons = [ "" "" "" ];
          format-muted = "";
          max-volume = 100;
          tooltip = false;
        };

        network = {
          format-ethernet = "";
          format-disconnected = "";
          format-linked = "";
          format-wifi = "{icon}";
          format-icons = [ "" "" "" ];
          tooltip = false;
        };
      };
    };

    style = ''
      * {
        text-shadow: none;
        font-size: .9rem;
        font-feature-settings: "tnum";
        font-family: Inter, FontAwesome6Pro;
        color: ${colors.white.gui};
      }

      window#waybar {
        background: none;
        min-height: 0;
      }

      window > box {
        background: none;
        margin: 10px 10px 0 10px;
      }

      .modules-left, .modules-right, .modules-center {
        background: ${shell};
        padding: 5px 10px 5px 10px;
        border-radius: 1rem;
      }

      tooltip {
        background: ${shell};
        padding: 5px 10px 5px 10px;
        border: none;
      }

      tooltip label {
        background: none;
        border: none;
      }

      #workspaces button {
        padding: 2px 8px 2px 8px;
        background: transparent;
      }

      #battery {
        padding-right: 14px;
      }
    '';
  };
}
