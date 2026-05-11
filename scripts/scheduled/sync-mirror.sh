#!/bin/bash

# Generic rsync mirror with trash-on-delete and retention.
#
# Usage:
#   sync-mirror.sh --name NAME --src DIR --dest DIR [--retain-days N] [--verbose]
#
# Required:
#   --name NAME       Identifier used for log/lock paths (e.g. "obsidian-backup")
#   --src DIR         Source directory
#   --dest DIR        Destination root. Mirror lives at $DIR/current/;
#                     deleted/overwritten files go to $DIR/_trash/<timestamp>/.
#
# Optional:
#   --retain-days N   Days to keep trash entries (default 30)
#   --verbose         Show rsync progress + stats (also via VERBOSE=1)
#   -h, --help        Show this help
#
# Logs:  /tmp/sync-<name>.log
# Lock:  /tmp/sync-<name>.lock.d
#
# Scheduled via per-job LaunchAgents (com.bryan.sync-<name>) that pass these
# flags in ProgramArguments.

set -uo pipefail

usage() {
    sed -n '3,21p' "$0" | sed 's/^# \{0,1\}//'
}

SYNC_NAME=""
SYNC_SRC=""
SYNC_DEST=""
RETAIN_DAYS=30
VERBOSE="${VERBOSE:-0}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)         SYNC_NAME="$2"; shift 2 ;;
        --src)          SYNC_SRC="$2"; shift 2 ;;
        --dest)         SYNC_DEST="$2"; shift 2 ;;
        --retain-days)  RETAIN_DAYS="$2"; shift 2 ;;
        --verbose|-v)   VERBOSE=1; shift ;;
        -h|--help)      usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

missing=()
[[ -z "$SYNC_NAME" ]] && missing+=(--name)
[[ -z "$SYNC_SRC"  ]] && missing+=(--src)
[[ -z "$SYNC_DEST" ]] && missing+=(--dest)
if (( ${#missing[@]} > 0 )); then
    echo "Missing required: ${missing[*]}" >&2
    usage >&2
    exit 2
fi

SOURCE="$SYNC_SRC"
DEST_ROOT="$SYNC_DEST"
LOG_FILE="/tmp/sync-${SYNC_NAME}.log"
LOCK_DIR="/tmp/sync-${SYNC_NAME}.lock.d"

MIRROR="$DEST_ROOT/current"
TRASH_ROOT="$DEST_ROOT/_trash"
RUN_TS="$(date '+%Y-%m-%d_%H-%M-%S')"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$SYNC_NAME] $*" >> "$LOG_FILE"
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
