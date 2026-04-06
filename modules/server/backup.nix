{ lib, config, pkgs, helpers, ... }:

with lib;
let
  cfg = config.modules.server;
  backup = cfg.backup;

  rclone = "${pkgs.rclone}/bin/rclone";
  coreutils = pkgs.coreutils;

  rcloneFlags = "--config ${backup.configPath}";

  pathType = types.submodule ({ name, ... }: {
    options = {
      name = mkOption {
        default = name;
        description = "Name used as the backup subdirectory in the remote. Defaults to the attribute name.";
        type = types.str;
      };

      path = mkOption {
        description = "Path to back up.";
        type = types.str;
      };

      sqlite = mkOption {
        default = null;
        description = "If set, use sqlite3 .backup on this database file instead of copying the path directly.";
        type = types.nullOr types.str;
      };

      extras = mkOption {
        default = [];
        description = "Additional files/directories within path to copy alongside a sqlite backup.";
        type = types.listOf types.str;
      };
    };
  });

  mkSqliteBackup = path: let
    sqlite = "${pkgs.sqlite}/bin/sqlite3";
  in ''
    echo "Backing up ${path.name}..."
    ${coreutils}/bin/mkdir -p "$TMP/${path.name}"
    ${sqlite} "${path.path}/${path.sqlite}" ".backup $TMP/${path.name}/${path.sqlite}"
    ${concatMapStringsSep "\n" (item: ''
      if [ -e "${path.path}/${item}" ]; then
        ${coreutils}/bin/cp -a "${path.path}/${item}" "$TMP/${path.name}/"
      fi
    '') path.extras}
    ${rclone} ${rcloneFlags} copy "$TMP/${path.name}" "r2-encrypted:${path.name}/$DATE/"
  '';

  mkSqlitePrune = path: ''
    CUTOFF=$(${coreutils}/bin/date -d '-${toString backup.retention} days' +%Y-%m-%d)
    ${rclone} ${rcloneFlags} lsd "r2-encrypted:${path.name}/" 2>/dev/null | ${coreutils}/bin/awk '{print $NF}' | while read -r dir; do
      if [[ "$dir" < "$CUTOFF" ]]; then
        ${rclone} ${rcloneFlags} purge "r2-encrypted:${path.name}/$dir/" || true
      fi
    done
  '';

  mkSyncBackup = path: ''
    echo "Syncing ${path.name}..."
    ${rclone} ${rcloneFlags} sync "${path.path}" "r2-encrypted:${path.name}/"
  '';

in helpers.linuxAttrs {
  options.modules.server.backup = {
    enable = mkOption {
      default = false;
      description = "Whether to enable automated backups to R2.";
      type = types.bool;
    };

    r2AccountId = mkOption {
      description = "Cloudflare account ID for R2 endpoint.";
      type = types.str;
    };

    bucket = mkOption {
      default = "backups";
      description = "R2 bucket name.";
      type = types.str;
    };

    schedule = mkOption {
      default = "*-*-* 04:00:00";
      description = "Systemd OnCalendar schedule for backups.";
      type = types.str;
    };

    retention = mkOption {
      default = 30;
      description = "Number of days to retain backups.";
      type = types.int;
    };

    configPath = mkOption {
      default = "/etc/rclone-backup.conf";
      description = "Path to the rclone configuration file.";
      type = types.str;
    };

    paths = mkOption {
      default = {};
      description = "Paths to back up. Other modules can append to this attrset.";
      type = types.attrsOf pathType;
    };
  };

  config = let
    sqlitePaths = filter (p: p.sqlite != null) (attrValues backup.paths);
    syncPaths = filter (p: p.sqlite == null) (attrValues backup.paths);
  in mkIf (cfg.enable && backup.enable) {
    environment.etc."rclone-backup.conf".text = ''
      [r2]
      type = s3
      provider = Cloudflare
      endpoint = https://${backup.r2AccountId}.r2.cloudflarestorage.com
      acl = private

      [r2-encrypted]
      type = crypt
      remote = r2:${backup.bucket}
    '';

    age.secrets."rclone-backup.env" = {
      symlink = true;
      path = "/run/secrets/rclone-backup.env";
      file = ./encrypt/rclone-backup.env.age;
    };

    systemd.services.backup = {
      description = "Backup services to R2";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = "/run/secrets/rclone-backup.env";
        ExecStart = pkgs.writeShellScript "backup" ''
          set -uo pipefail
          FAILED=0
          DATE=$(${coreutils}/bin/date +%Y-%m-%d)
          TMP=$(${coreutils}/bin/mktemp -d)
          trap '${coreutils}/bin/rm -rf "$TMP"' EXIT

          ${concatMapStringsSep "\n" (p: ''
            (set -e; ${mkSqliteBackup p}) || FAILED=1
          '') sqlitePaths}

          ${concatMapStringsSep "\n" (p: ''
            (set -e; ${mkSqlitePrune p}) || true
          '') sqlitePaths}

          ${concatMapStringsSep "\n" (p: ''
            (set -e; ${mkSyncBackup p}) || FAILED=1
          '') syncPaths}

          exit "$FAILED"
        '';
      };
    };

    systemd.timers.backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = backup.schedule;
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
  };
}
