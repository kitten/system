{ lib, pkgs, user, ... }:

let
  group = "share";
in {
  hardware.graphics.enable = lib.mkDefault true;

  age.secrets."rclone.conf" = {
    symlink = true;
    path = "/run/secrets/rclone.conf";
    file = ./encrypt/rclone.conf.age;
    owner = "jellyfin";
    group = "${group}";
  };

  users.users."${user}".extraGroups = [ "${group}" ];

  users.groups.share.gid = 1001;

  services.jellyfin = {
    enable = true;
    openFirewall = false;
    group = "${group}";
  };

  systemd.services."rclone-sync@" = {
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

  systemd.timers."rclone-sync@" = {
    description = "Sync files between different remotes via rclone periodically";
    timerConfig = {
      OnBootSec = "15min";
      OnUnitActiveSec="8h";
      Persistent = true;
    };
  };

  systemd.targets.rclone-sync = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "rclone-sync@movies.timer" "rclone-sync@series.timer" ];
  };
}
