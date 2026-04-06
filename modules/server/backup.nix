{ lib, config, pkgs, helpers, ... }:

with lib;
let
  cfg = config.modules.server;
  backup = cfg.backup;

  rclone = "${pkgs.rclone}/bin/rclone";
  coreutils = pkgs.coreutils;

  rcloneConf = "/etc/rclone-backup.conf";
  rcloneFlags = "--config ${rcloneConf} --skip-links --ignore-errors --fast-list --size-only";

  pathType = types.submodule ({ name, ... }: {
    options = {
      name = mkOption {
        default = name;
        type = types.str;
        internal = true;
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

      exclude = mkOption {
        default = [];
        description = "Patterns to exclude from sync backups.";
        type = types.listOf types.str;
      };

    };
  });

  mkSyncBackup = path: let
    sqliteExcludes = optionals (path.sqlite != null)
      (map (s: "--exclude ${escapeShellArg s}") [ path.sqlite "${path.sqlite}-shm" "${path.sqlite}-wal" ]);
    userExcludes = map (p: "--exclude ${escapeShellArg p}") path.exclude;
    excludeFlags = concatStringsSep " " (sqliteExcludes ++ userExcludes);
  in ''
    echo "Syncing ${path.name}..."
    ${rclone} ${rcloneFlags} sync ${excludeFlags} "${path.path}" "r2crypt:${path.name}/"
  '';

  mkSqliteBackup = path: let
    sqlite = "${pkgs.sqlite}/bin/sqlite3";
  in ''
    echo "Backing up ${path.name} database..."
    ${coreutils}/bin/mkdir -p "$TMP/${path.name}"
    ${sqlite} "${path.path}/${path.sqlite}" ".backup $TMP/${path.name}/${path.sqlite}"
    ${rclone} ${rcloneFlags} copy "$TMP/${path.name}" "r2crypt:${path.name}-db/$DATE/"
  '';

  mkSqlitePrune = path: ''
    ${rclone} ${rcloneFlags} delete --min-age ${toString backup.retention}d "r2crypt:${path.name}-db/"
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

    paths = mkOption {
      default = {};
      description = "Paths to back up. Other modules can append to this attrset.";
      type = types.attrsOf pathType;
    };
  };

  config = let
    allPaths = attrValues backup.paths;
    sqlitePaths = filter (p: p.sqlite != null) allPaths;
  in mkIf (cfg.enable && backup.enable) {

    environment.etc."rclone-backup.conf".text = ''
      [r2]
      type = s3
      provider = Cloudflare
      endpoint = https://${backup.r2AccountId}.r2.cloudflarestorage.com
      acl = private

      [r2crypt]
      type = crypt
      remote = r2:${backup.bucket}
      filename_encryption = off
      directory_name_encryption = false
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
            (set -e; ${mkSyncBackup p}) || FAILED=1
          '') allPaths}

          ${concatMapStringsSep "\n" (p: ''
            (set -e; ${mkSqliteBackup p}) || FAILED=1
          '') sqlitePaths}

          ${concatMapStringsSep "\n" (p: ''
            (set -e; ${mkSqlitePrune p}) || true
          '') sqlitePaths}

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
