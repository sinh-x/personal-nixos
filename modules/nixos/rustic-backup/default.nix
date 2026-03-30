{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.rustic-backup;

  backupScript = pkgs.writeShellScript "rustic-backup" ''
    set -euo pipefail

    DATA_DIR="${cfg.dataDir}"
    STAGING_DIR="/tmp/rustic-backup-staging"
    RUSTIC_PROFILE="${cfg.profile}"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    log() { echo "[$TIMESTAMP] $*"; }

    cleanup() {
      if [[ -d "$STAGING_DIR" ]]; then
        rm -rf "$STAGING_DIR"
        log "Cleanup: removed staging directory"
      fi
    }
    trap cleanup EXIT

    log "Starting backup of $DATA_DIR"

    # Init rustic repo if it doesn't exist yet
    if ! ${pkgs.rustic}/bin/rustic -P "$RUSTIC_PROFILE" snapshots &>/dev/null; then
      log "Rustic repo not found, initializing..."
      ${pkgs.rustic}/bin/rustic -P "$RUSTIC_PROFILE" init 2>&1
      log "Rustic repo initialized"
    fi

    mkdir -p "$STAGING_DIR"

    # Backup database using python3 sqlite3 for consistency
    DB_SRC="$DATA_DIR/baker.db"
    DB_DST="$STAGING_DIR/baker.db"

    if [[ -f "$DB_SRC" ]]; then
      log "Backing up database: $DB_SRC"
      ${pkgs.python3}/bin/python3 -c "
    import sqlite3, sys
    try:
        with sqlite3.connect('$DB_SRC') as conn:
            conn.backup(sqlite3.connect('$DB_DST'))
        print('Database backup successful')
    except Exception as e:
        print(f'Database backup failed: {e}', file=sys.stderr)
        sys.exit(1)
    "
      log "Database backup complete"
    else
      log "WARNING: Database not found at $DB_SRC"
    fi

    # Copy photos and logs to staging area
    if [[ -d "$DATA_DIR/photos" ]]; then
      log "Copying photos/"
      cp -r "$DATA_DIR/photos" "$STAGING_DIR/"
    fi

    if [[ -d "$DATA_DIR/logs" ]]; then
      log "Copying logs/"
      cp -r "$DATA_DIR/logs" "$STAGING_DIR/"
    fi

    # Run rustic backup on staging directory
    log "Running rustic backup..."
    ${pkgs.rustic}/bin/rustic -P "$RUSTIC_PROFILE" \
      backup "$STAGING_DIR" \
      --tag "date=$(date '+%Y-%m-%d')" \
      --tag "host=$(${pkgs.inetutils}/bin/hostname)" \
      --tag "type=full" 2>&1

    log "Rustic backup complete"

    # Run rustic forget with retention policy
    log "Running rustic forget --prune..."
    ${pkgs.rustic}/bin/rustic -P "$RUSTIC_PROFILE" \
      forget --prune \
      --keep-daily ${toString cfg.retention.daily} \
      --keep-weekly ${toString cfg.retention.weekly} \
      --keep-monthly ${toString cfg.retention.monthly} 2>&1

    log "Rustic forget --prune complete"
    log "Backup completed successfully"
  '';
in
{
  options.modules.rustic-backup = {
    enable = mkEnableOption "Rustic backup to Wasabi";

    profile = mkOption {
      type = types.str;
      description = "Rustic profile name (from ~/.config/rustic/<profile>.toml)";
    };

    dataDir = mkOption {
      type = types.str;
      description = "Path to the data directory to backup";
    };

    calendar = mkOption {
      type = types.str;
      default = "22:00";
      description = "systemd OnCalendar schedule for the backup timer";
    };

    user = mkOption {
      type = types.str;
      default = "sinh";
      description = "User to run the backup as";
    };

    retention = {
      daily = mkOption {
        type = types.int;
        default = 7;
        description = "Number of daily snapshots to keep";
      };
      weekly = mkOption {
        type = types.int;
        default = 4;
        description = "Number of weekly snapshots to keep";
      };
      monthly = mkOption {
        type = types.int;
        default = 3;
        description = "Number of monthly snapshots to keep";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.rustic-backup = {
      description = "Rustic backup to Wasabi";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [
        rclone
        coreutils
      ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = backupScript;
        Nice = 10;
        TimeoutStartSec = "2h";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.timers.rustic-backup = {
      description = "Rustic backup timer";
      timerConfig = {
        OnCalendar = cfg.calendar;
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
