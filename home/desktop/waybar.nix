{ pkgs, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) colors mkLuaSyntax;
in {
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        exclusive = true;
        passthrough = false;
        fixed-center = true;
        gtk-layer-shell = false;
        spacing = 12;

        modules-left = [ "custom/wofi" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "network" "wireplumber" "battery" ];

        "custom/wofi" = {
          format = "Search";
          on-click = "${pkgs.wofi}/bin/wofi";
        };

        clock = {
          interval = 60;
          format = "{:%a %b %d %H:%M}";
          tooltip = true;
          tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
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
          tooltip = true;
        };

        wireplumber = {
          format = "{icon}";
          format-icons = [ "" "" "" ];
          format-muted = "";
          max-volume = 100;
          tooltip = true;
          tooltip-format = " {volume}% {node_name}";
        };

        network = {
          format-ethernet = "";
          format-disconnected = "";
          format-linked = "";
          format-wifi = "{icon}";
          format-icons = [ "" "" "" ];
          tooltip = true;
          tooltip-format = "{icon} {ifname} to {gwaddr}";
          tooltip-format-wifi = "{icon} {essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{icon} {ifname} via {ipaddr}";
          tooltip-format-disconnected = "Disconnected";
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
        background: alpha(${colors.split.gui}, 0.8);
        padding: 5px 10px 5px 10px;
        border-radius: 1rem;
      }

      tooltip {
        background: alpha(${colors.split.gui}, 0.8);
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
