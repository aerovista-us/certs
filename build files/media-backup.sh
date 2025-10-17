
#!/usr/bin/env bash
set -euo pipefail

SRC="/srv/media"
SNAP_DIR="/srv/.snapshots"
BACKUP_MOUNT="/mnt/backup1"   # change to your external SSD mount point

timestamp() { date +"%F-%H%M"; }

log(){ echo "[media-backup] $*"; }

# Snapshot if btrfs present
if findmnt -n -o FSTYPE "$SRC" | grep -qi btrfs; then
  mkdir -p "$SNAP_DIR"
  SNAP_NAME="media-$(timestamp)"
  log "Creating read-only btrfs snapshot: $SNAP_DIR/$SNAP_NAME"
  btrfs subvolume snapshot -r "$SRC" "$SNAP_DIR/$SNAP_NAME" || true

  # Keep last 7 snapshots
  ls -1t "$SNAP_DIR" | grep '^media-' | tail -n +8 | while read -r old; do
    log "Deleting old snapshot $old"
    btrfs subvolume delete "$SNAP_DIR/$old" || true
  done
else
  log "Non-btrfs filesystem; skipping snapshot."
fi

# Off-box rsync if backup drive present
if mountpoint -q "$BACKUP_MOUNT"; then
  log "Syncing to $BACKUP_MOUNT/media"
  rsync -aHAX --delete --info=progress2 "$SRC/" "$BACKUP_MOUNT/media/"
else
  log "Backup mount $BACKUP_MOUNT not found; skipping rsync."
fi

log "Done."
