{ pkgs, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) colors shell;
  swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";
  wait = "${pkgs.coreutils}/bin/sleep 0.1";
in {
  services = {
    network-manager-applet.enable = true;
    blueman-applet.enable = true;
    mpris-proxy.enable = true;
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        passthrough = false;
        fixed-center = true;
        spacing = 12;

        modules-left = [ "custom/wofi" ];
        modules-center = [ "clock" "custom/swaync" ];
        modules-right = [ "tray" "wireplumber" "battery" ];

        "custom/wofi" = {
          format = "";
          on-click = "${wait} && ${pkgs.wofi}/bin/wofi";
          tooltip = false;
          escape = true;
        };

        "custom/swaync" = {
          format = "{icon}";
          tooltip = false;
          escape = true;
          return-type = "json";
          on-click = "${wait} && ${swaync-client} -t -sw";
          on-click-right = "${wait} && ${swaync-client} -d -sw";
          exec = "${swaync-client} -swb";
          format-icons = {
            notification = " <span foreground='${colors.brightYellow.gui}'></span>";
            none = "";
            dnd-notification = " <span foreground='${colors.brightYellow.gui}'></span>";
            dnd-none = "";
            inhibited-notification = " <span foreground='${colors.brightYellow.gui}'></span>";
            inhibited-none = "";
            dnd-inhibited-notification = " <span foreground='${colors.brightYellow.gui}'></span>";
            dnd-inhibited-none = "";
          };
        };

        tray = {
          icon-size = 16;
          spacing = 8;
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
    '';
  };
}
