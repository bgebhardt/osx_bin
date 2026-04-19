#!/bin/bash

# Sync Obsidian vault from OneDrive to Cloud-Drive as a recoverable backup.
#
# Strategy: rsync mirror with a timestamped "_trash" dir.
#   - Current state lives at  $DEST_ROOT/current/
#   - Anything deleted or overwritten during a run is moved to
#     $DEST_ROOT/_trash/<run-timestamp>/ preserving its relative path.
#   - This protects against Claude Code or other tools corrupting/deleting
#     files in the main ~/OneDrive/Obsidian/ vault: the bad state propagates
#     to current/, but the prior-good version is kept under _trash/.
#   - Old _trash/ entries older than $RETAIN_DAYS are pruned.
#
# Scheduled via com.bryan.sync-obsidian-backup LaunchAgent.

set -uo pipefail

SOURCE="${OBSIDIAN_SYNC_SRC:-$HOME/OneDrive/Obsidian}"
DEST_ROOT="${OBSIDIAN_SYNC_DEST:-$HOME/Cloud-Drive/Obsidian}"
RETAIN_DAYS="${OBSIDIAN_SYNC_RETAIN_DAYS:-30}"
VERBOSE="${VERBOSE:-0}"
LOG_FILE="/tmp/sync-obsidian-backup.log"
LOCK_DIR="/tmp/sync-obsidian-backup.lock.d"

MIRROR="$DEST_ROOT/current"
TRASH_ROOT="$DEST_ROOT/_trash"
RUN_TS="$(date '+%Y-%m-%d_%H-%M-%S')"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

# Atomic lock using mkdir to prevent overlapping runs.
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    # If the lock is older than 6 hours, it's stale — clear and retry once.
    if [[ -n "$(find "$LOCK_DIR" -maxdepth 0 -mmin +360 2>/dev/null)" ]]; then
        log "Stale lock detected; removing and continuing."
        rmdir "$LOCK_DIR" 2>/dev/null
        mkdir "$LOCK_DIR" 2>/dev/null || { log "Could not acquire lock; exiting."; exit 0; }
    else
        log "Another run in progress; exiting."
        exit 0
    fi
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

if [[ ! -d "$SOURCE" ]]; then
    log "Source $SOURCE not found; skipping."
    exit 0
fi

# Guard against mirroring an empty/unmounted source over a good backup.
if [[ -z "$(ls -A "$SOURCE" 2>/dev/null)" ]]; then
    log "Source $SOURCE is empty; skipping to avoid wiping backup."
    exit 0
fi

mkdir -p "$MIRROR" "$TRASH_ROOT"

RSYNC_OPTS=(
    -a                       # archive (perms, times, symlinks, recursive)
    -E                       # preserve macOS extended attributes
    --delete                 # remove files from MIRROR that no longer exist in SOURCE...
    --backup                 # ...but first move them to the backup dir
    --backup-dir="$TRASH_ROOT/$RUN_TS"
    # macOS / Obsidian noise
    --exclude='.DS_Store'
    --exclude='._*'
    --exclude='.trash/'
    --exclude='_trash/'
    # Obsidian UI state (changes on every keystroke, not worth backing up)
    --exclude='.obsidian/workspace*.json'
    --exclude='.obsidian/cache'
    # Plugin caches (derived data, rebuilt automatically, often huge/emoji-named)
    --exclude='.smart-env/'
    --exclude='.obsidian/plugins/smart-connections/.smart-env/'
    --exclude='.obsidian/plugins/*/cache/'
    --exclude='.obsidian/plugins/*/data-cache.json'
    # VCS (if you version-control your vault — keep the working copy, skip git objects)
    --exclude='.git/'
    --exclude='.obsidian-git-data/'
)

if [[ "$VERBOSE" != "0" ]]; then
    RSYNC_OPTS+=(-v --human-readable --info=progress2,stats1)
fi

log "Starting sync: $SOURCE -> $MIRROR (trash -> $TRASH_ROOT/$RUN_TS)"
rsync "${RSYNC_OPTS[@]}" "$SOURCE/" "$MIRROR/" >> "$LOG_FILE" 2>&1
RC=$?

if [[ $RC -ne 0 ]]; then
    log "rsync exited with status $RC"
fi

# If no files moved to trash this run, the dir was never created — tidy up.
if [[ -d "$TRASH_ROOT/$RUN_TS" ]] && [[ -z "$(ls -A "$TRASH_ROOT/$RUN_TS" 2>/dev/null)" ]]; then
    rmdir "$TRASH_ROOT/$RUN_TS" 2>/dev/null
fi

# Prune old trash entries.
if [[ -d "$TRASH_ROOT" ]]; then
    find "$TRASH_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime "+$RETAIN_DAYS" -print0 2>/dev/null |
        while IFS= read -r -d '' old; do
            log "Pruning old trash: $old"
            rm -rf "$old"
        done
fi

log "Sync complete (rsync rc=$RC)"
exit $RC
