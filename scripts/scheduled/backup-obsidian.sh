#!/bin/bash

# Back up ~/Obsidian Master to Backblaze B2 using restic.
#
# Features:
#   - Incremental, deduplicated, encrypted snapshots
#   - Retention: 30 daily, 4 weekly, 6 monthly snapshots
#   - Lock file to prevent overlapping runs
#
# Credentials:  ~/.config/restic/obsidian-env
# Logs:         /tmp/backup-obsidian.log
# Lock:         /tmp/backup-obsidian.lock.d
#
# Restore examples:
#   restic snapshots                              # list all snapshots
#   restic restore latest --target ~/restore/     # restore latest
#   restic restore abc123 --target ~/restore/     # restore specific snapshot
#   restic mount /mnt/restic                      # browse snapshots as filesystem
#
# Scheduled via LaunchAgent: com.bryan.backup-obsidian

# The easiest path to setting up Obsidian on a new mac is to restore your entire vault directory from backup, since that preserves all your plugins, themes, and settings. Here's the recommended process:
# 1. Install Obsidian and open it once (creates the app but no vaults yet)
# 2. Restore your vault from restic:
# bash
#    This restores ~/Obsidian Master with all your vaults, plugins, themes, and configs intact.
# 3. Open the vaults in Obsidian — File → Open Vault → choose e.g. ~/Obsidian Master/Obsidian/Personal
# 4. Set up Remotely Save — it'll already be installed (it was in .obsidian/plugins/). Configure it with your Backblaze credentials so ongoing data stays in sync between Macs.
# 5. Set up the restic backup on the new Mac too — copy backup-obsidian.sh, the plist, and obsidian-env from your ~/bin/scripts/scheduled/ repo, then run install-scheduled-scripts.sh.
# Since your ~/bin is a git repo, steps 5 is really just cloning that repo on the new Mac and running the install script. Remotely Save handles day-to-day sync; restic handles the full restore and ongoing backup.

set -uo pipefail

NAME="backup-obsidian"
SOURCE="$HOME/Obsidian Master"
ENV_FILE="$HOME/.config/restic/obsidian-env"
LOG_FILE="/tmp/${NAME}.log"
LOCK_DIR="/tmp/${NAME}.lock.d"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$NAME] $*" >> "$LOG_FILE"
}

# ── Load credentials ──────────────────────────────────────────────
if [[ ! -f "$ENV_FILE" ]]; then
    log "Credentials file not found: $ENV_FILE"
    exit 1
fi
# shellcheck disable=SC1090
source "$ENV_FILE"

# ── Acquire lock ──────────────────────────────────────────────────
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
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

# ── Validate source ──────────────────────────────────────────────
if [[ ! -d "$SOURCE" ]]; then
    log "Source $SOURCE not found; skipping."
    exit 0
fi
if [[ -z "$(ls -A "$SOURCE" 2>/dev/null)" ]]; then
    log "Source $SOURCE is empty; skipping to avoid empty snapshot."
    exit 0
fi

# ── Initialize repo if needed ────────────────────────────────────
if ! restic cat config >/dev/null 2>&1; then
    log "Repository not initialized; running restic init."
    restic init >> "$LOG_FILE" 2>&1
    RC=$?
    if [[ $RC -ne 0 ]]; then
        log "restic init failed (rc=$RC); exiting."
        exit 1
    fi
fi

# ── Backup ───────────────────────────────────────────────────────
log "Starting backup: $SOURCE"
restic backup "$SOURCE" \
    --exclude='.DS_Store' \
    --exclude='._*' \
    --exclude='.trash/' \
    --exclude='.obsidian/workspace*.json' \
    --exclude='.obsidian/cache' \
    --exclude='.smart-env/' \
    --exclude='.obsidian/plugins/smart-connections/.smart-env/' \
    --exclude='.obsidian/plugins/*/cache/' \
    --exclude='.obsidian/plugins/*/data-cache.json' \
    --exclude='.git/' \
    --exclude='.obsidian-git-data/' \
    >> "$LOG_FILE" 2>&1
RC=$?

if [[ $RC -ne 0 ]]; then
    log "restic backup exited with status $RC"
    exit $RC
fi
log "Backup complete."

# ── Prune old snapshots ─────────────────────────────────────────
log "Pruning old snapshots..."
restic forget \
    --keep-daily    30 \
    --keep-weekly    4 \
    --keep-monthly   6 \
    --prune \
    >> "$LOG_FILE" 2>&1
RC=$?

if [[ $RC -ne 0 ]]; then
    log "restic forget/prune exited with status $RC"
fi

log "All done (forget rc=$RC)."
exit 0
