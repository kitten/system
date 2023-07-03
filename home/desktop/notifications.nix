{ pkgs, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) colors lightStroke shell;
  package = pkgs.swaynotificationcenter;
in {
  home.packages = [ package ];

  xdg.configFile."swaync/config.json".text = builtins.toJSON {
    positionX = "right";
    positionY = "top";
    layer = "top";
    control-center-positionX = "right";
    control-center-positionY = "top";
    control-center-layer = "overlay";
    layer-shell = true;
    fit-to-screen = false;
  };

  xdg.configFile."swaync/style.css".text = ''
    * {
      text-shadow: none;
      font-family: Inter, FontAwesome6Pro;
    }

    .blank-window {
      background: transparent;
      margin: 0;
      padding: 0;
    }

    .control-center {
      background: ${shell};
      border: 1px solid ${lightStroke};
      margin: 8px;
      padding: 1rem;
      border-radius: 1rem;
      color: ${colors.white.gui};
    }

    .notification {
      background: ${shell};
      border: 1px solid ${lightStroke};
      padding: 5px 10px 5px 10px;
      border-radius: 1rem;
      color: ${colors.white.gui};
      box-shadow: none;
      font-size: .9rem;
    }

    .notification > * {
      background: none;
      border: none;
      padding: 0;
      margin: 0;
    }

    .notification-content {
      background: none;
      padding: 6px;
      border-radius: 12px;
    }

    .notification-row {
      outline: none;
      background: none;
      border: none;
    }

    .time {
      background: none;
    }

    .summary {
      background: none;
    }

    .body {
      background: none;
    }
  '';

  systemd.user.services.swaync = {
    Unit = {
      Description = "Swaync notification daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };

    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notification";
      ExecStart = "${package}/bin/swaync";
      ExecReload = "${package}/bin/swaync-client --reload-config ; ${package}/bin/swaync-client --reload-css";
      Restart = "on-failure";
    };
  };

  xdg.dataFile."dbus-1/services/swaync.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.Notification
    Exec=${package}/bin/swaync
    SystemdService=swaync.service
  '';
}
