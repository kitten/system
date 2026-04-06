# Restore a backup from R2.
#
# On the server (defaults auto-detected):
#   restoreBackup vaultwarden              # list available backups
#   restoreBackup vaultwarden 2026-04-05   # restore specific date
#
# On a fresh machine (specify paths explicitly):
#   restoreBackup --config ./rclone.conf --env ./secrets.env vaultwarden 2026-04-05
#
# Default paths (managed by NixOS):
#   Config:  /etc/rclone-backup.conf        (modules/server/backup.nix)
#   Secrets: /run/secrets/rclone-backup.env (agenix, modules/server/backup.nix)

{ pkgs, ... }:

let
  rclone = "${pkgs.rclone}/bin/rclone";
  coreutils = pkgs.coreutils;

  defaultConf = "/etc/rclone-backup.conf";
  defaultEnv = "/run/secrets/rclone-backup.env";
in
  toString (pkgs.writers.writeBash "restoreBackup" ''
    set -euo pipefail

    REMOTE="r2crypt"
    CONFIG="${defaultConf}"
    ENV_FILE="${defaultEnv}"
    SERVICE=""
    DATE=""

    usage() {
      echo "Usage: restoreBackup [--config <rclone.conf>] [--env <secrets.env>] <service> [date]"
      echo ""
      echo "  --config    Path to rclone config (default: ${defaultConf})"
      echo "  --env       Path to rclone secrets env file (default: ${defaultEnv})"
      echo "  service     Name of the backup to restore (e.g. vaultwarden, tangled)"
      echo "  date        Backup date (YYYY-MM-DD) for snapshot backups. Omit to list dates or download synced backups."
      echo ""
      echo "Snapshot backups (sqlite) are stored by date. Synced backups (directories) are downloaded directly."
      echo ""
      echo "Examples:"
      echo "  restoreBackup vaultwarden                    # list available snapshot dates"
      echo "  restoreBackup vaultwarden 2026-04-05         # restore specific snapshot"
      echo "  restoreBackup tangled                        # download synced backup"
      echo "  restoreBackup --config ./rclone.conf --env ./secrets.env tangled"
      exit 1
    }

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --config) CONFIG="$2"; shift 2 ;;
        --env) ENV_FILE="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) if [[ -z "$SERVICE" ]]; then SERVICE="$1"; else DATE="$1"; fi; shift ;;
      esac
    done

    if [[ -z "$SERVICE" ]]; then
      usage
    fi

    if [[ ! -f "$CONFIG" ]]; then
      echo "Error: rclone config not found at $CONFIG. Use --config to specify one."
      exit 1
    fi

    if [[ -f "$ENV_FILE" ]]; then
      set -a
      source "$ENV_FILE"
      set +a
    else
      echo "Warning: No env file at $ENV_FILE. Rclone credentials must be set in environment."
    fi

    RCLONE="${rclone} --config $CONFIG"

    if [[ -n "$DATE" ]]; then
      # Snapshot restore (sqlite backups with date folders)
      echo "Downloading $SERVICE snapshot from $DATE..."
      OUT="/var/tmp/restore-$SERVICE-$DATE"
      ${coreutils}/bin/rm -rf "$OUT"
      ${coreutils}/bin/mkdir -p "$OUT"
      $RCLONE copy "$REMOTE/$SERVICE/$DATE/" "$OUT/"
    else
      # Check if this is a snapshot backup (has date subdirectories) or a synced backup
      SUBDIRS=$($RCLONE lsd "$REMOTE/$SERVICE/" 2>/dev/null | ${coreutils}/bin/awk '{print $NF}')
      if echo "$SUBDIRS" | ${coreutils}/bin/grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        echo "Available $SERVICE snapshots:"
        echo "$SUBDIRS" | ${coreutils}/bin/sed 's/^/  /'
        exit 0
      fi

      # Synced backup — download directly
      echo "Downloading $SERVICE synced backup..."
      OUT="/var/tmp/restore-$SERVICE"
      ${coreutils}/bin/rm -rf "$OUT"
      ${coreutils}/bin/mkdir -p "$OUT"
      $RCLONE copy "$REMOTE/$SERVICE/" "$OUT/"
    fi

    echo ""
    echo "Downloaded to: $OUT"
    echo ""
    echo "Contents:"
    ${coreutils}/bin/ls -la "$OUT/"
    echo ""
    echo "To restore, stop the service and copy the files into place. For example:"
    echo ""
    echo "  systemctl stop $SERVICE"
    for item in "$OUT"/*; do
      base=$(${coreutils}/bin/basename "$item")
      echo "  cp -a $OUT/$base /var/lib/$SERVICE/"
    done
    echo "  systemctl start $SERVICE"
  '')
