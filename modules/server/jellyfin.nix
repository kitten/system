{ lib, config, pkgs, user, ... }:

with lib;
let
  cfgRoot = config.modules.server;
  cfg = config.modules.server.jellyfin;

  group = "share";
in {
  options.modules.server.jellyfin = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Jellyfin server.";
      type = types.bool;
    };

    sync = mkOption {
      default = cfg.enable;
      description = "Whether to sync files from remotes";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfgRoot.enable) {
    hardware.graphics.enable = mkDefault true;

    users.users."${user}".extraGroups = [ "${group}" ];

    users.groups.share.gid = 1001;

    services.jellyfin = {
      enable = true;
      openFirewall = false;
      group = "${group}";
    };

    age.secrets."rclone.conf" = mkIf cfg.sync {
      symlink = true;
      path = "/run/secrets/rclone.conf";
      file = ./encrypt/rclone.conf.age;
      owner = "jellyfin";
      group = "${group}";
    };

    systemd.services."rclone-sync@" = mkIf cfg.sync {
      wants = [ "network-online.target" ];
      description = "Sync files between different remotes via rclone";
      stopIfChanged = false;
      serviceConfig = {
        Type = "simple";
        User = "jellyfin";
        Group = "${group}";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone \
            --config /run/secrets/rclone.conf \
            -P copy \
            -u \
            --max-age 24h \
            --multi-thread-streams 0 \
            putio:%I /share/media/%I
        '';
      };
    };

    systemd.timers."rclone-sync@" = mkIf cfg.sync {
      description = "Sync files between different remotes via rclone periodically";
      timerConfig = {
        OnBootSec = "15min";
        OnUnitActiveSec="8h";
        Persistent = true;
      };
    };

    systemd.targets.rclone-sync = mkIf cfg.sync {
      wantedBy = [ "multi-user.target" ];
      wants = [ "rclone-sync@movies.timer" "rclone-sync@series.timer" ];
    };
  };
}
