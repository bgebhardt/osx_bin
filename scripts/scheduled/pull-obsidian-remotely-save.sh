#!/bin/bash

# Pull all configured Obsidian Remotely Save Backblaze buckets.
#
# This script reads one env file containing the vault list and per-vault
# Backblaze S3 credentials, then calls pull-remotely-save.sh once per vault.
#
# Credentials: ~/.config/rclone/obsidian-remotely-save.env
# Example:     ~/bin/scripts/scheduled/obsidian-remotely-save.env.example
# Local copy:  ~/Obsidian Remotely Save/<vault>/current
# Logs:        /tmp/pull-obsidian-remotely-save.log
#
# Usage:
#   pull-obsidian-remotely-save.sh [--vault NAME] [--dry-run] [--verbose] [--trash-mode keep|delete]
#
#   --vault NAME   Only pull this one vault instead of all configured vaults.
#
# Interactive terminal runs stream progress to stdout. Per-vault rclone stats
# are also written to /tmp/pull-remotely-save-<vault>.log every 15 seconds.
#
# The default trash mode is "keep", which moves deleted/overwritten local files
# to <vault>/_trash/<timestamp>. Use "delete" to let rclone delete missing files
# and overwrite changed files in place.

set -uo pipefail

NAME="obsidian-remotely-save"
ENV_FILE="$HOME/.config/rclone/obsidian-remotely-save.env"
DEFAULT_DEST_ROOT="$HOME/Obsidian Remotely Save"
DEST_ROOT_ARG=""
DEST_ROOT="$DEFAULT_DEST_ROOT"
LOG_FILE="/tmp/pull-${NAME}.log"
LOCK_DIR="/tmp/pull-${NAME}.lock.d"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKER="$SCRIPT_DIR/pull-remotely-save.sh"
DRY_RUN=0
TRASH_MODE="${TRASH_MODE:-keep}"
VERBOSE="${VERBOSE:-0}"
VAULT_FILTER=""

usage() {
    awk 'NR >= 3 { if ($0 !~ /^#/) exit; sub(/^# ?/, ""); print }' "$0"
}

log() {
    local msg
    msg="$(date '+%Y-%m-%d %H:%M:%S') [$NAME] $*"
    echo "$msg" >> "$LOG_FILE"
    if [[ -t 1 ]]; then
        echo "$msg"
    fi
}

die() {
    log "$*"
    echo "$*" >&2
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --env-file)    ENV_FILE="$2"; shift 2 ;;
        --dest-root)   DEST_ROOT_ARG="$2"; shift 2 ;;
        --vault)       VAULT_FILTER="$2"; shift 2 ;;
        --trash-mode)  TRASH_MODE="$2"; shift 2 ;;
        --dry-run)     DRY_RUN=1; shift ;;
        --verbose|-v)  VERBOSE=1; shift ;;
        -h|--help)     usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

case "$TRASH_MODE" in
    keep|delete) ;;
    *) echo "Invalid --trash-mode: $TRASH_MODE (expected keep or delete)" >&2; exit 2 ;;
esac

if [[ ! -x "$WORKER" ]]; then
    die "Worker script not executable: $WORKER"
fi

if [[ ! -f "$ENV_FILE" ]]; then
    die "Credential file not found: $ENV_FILE"
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

DEST_ROOT="${DEST_ROOT_ARG:-${OBSIDIAN_REMOTELY_SAVE_DEST_ROOT:-$DEFAULT_DEST_ROOT}}"

if [[ -z "${OBSIDIAN_REMOTELY_SAVE_VAULTS:-}" ]]; then
    die "Set OBSIDIAN_REMOTELY_SAVE_VAULTS in $ENV_FILE"
fi

if [[ -n "$VAULT_FILTER" ]]; then
    MATCH=0
    for VAULT in $OBSIDIAN_REMOTELY_SAVE_VAULTS; do
        [[ "$VAULT" == "$VAULT_FILTER" ]] && MATCH=1
    done
    [[ "$MATCH" == "1" ]] || die "Vault '$VAULT_FILTER' not found in OBSIDIAN_REMOTELY_SAVE_VAULTS ($OBSIDIAN_REMOTELY_SAVE_VAULTS)"
    OBSIDIAN_REMOTELY_SAVE_VAULTS="$VAULT_FILTER"
fi

if [[ "$DEST_ROOT" == *:* ]]; then
    die "Destination root must be a local path, got: $DEST_ROOT"
fi

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

OVERALL_RC=0
log "Starting configured vault pulls: $OBSIDIAN_REMOTELY_SAVE_VAULTS (trash-mode=$TRASH_MODE, dest-root=$DEST_ROOT)"

for VAULT in $OBSIDIAN_REMOTELY_SAVE_VAULTS; do
    VAULT_ENV="$(printf '%s' "$VAULT" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9]/_/g')"

    BUCKET_VAR="OBSIDIAN_REMOTELY_SAVE_${VAULT_ENV}_BUCKET"
    ENDPOINT_VAR="OBSIDIAN_REMOTELY_SAVE_${VAULT_ENV}_ENDPOINT"
    KEY_ID_VAR="OBSIDIAN_REMOTELY_SAVE_${VAULT_ENV}_KEY_ID"
    APPLICATION_KEY_VAR="OBSIDIAN_REMOTELY_SAVE_${VAULT_ENV}_APPLICATION_KEY"

    BUCKET="${!BUCKET_VAR:-}"
    ENDPOINT="${!ENDPOINT_VAR:-s3.us-west-001.backblazeb2.com}"
    KEY_ID="${!KEY_ID_VAR:-}"
    APPLICATION_KEY="${!APPLICATION_KEY_VAR:-}"

    if [[ -z "$BUCKET" || -z "$KEY_ID" || -z "$APPLICATION_KEY" ]]; then
        log "Skipping $VAULT: missing $BUCKET_VAR, $KEY_ID_VAR, or $APPLICATION_KEY_VAR"
        OVERALL_RC=1
        continue
    fi

    ARGS=(
        --name "$VAULT"
        --bucket "$BUCKET"
        --endpoint "$ENDPOINT"
        --env-file "$ENV_FILE"
        --dest "$DEST_ROOT/$VAULT"
        --trash-mode "$TRASH_MODE"
    )

    if [[ "$DRY_RUN" != "0" ]]; then
        ARGS+=(--dry-run)
    fi
    if [[ "$VERBOSE" != "0" ]]; then
        ARGS+=(--verbose)
    fi

    log "Pulling vault $VAULT from bucket $BUCKET"
    REMOTELY_SAVE_KEY_ID="$KEY_ID" \
        REMOTELY_SAVE_APPLICATION_KEY="$APPLICATION_KEY" \
        REMOTELY_SAVE_ENDPOINT="$ENDPOINT" \
        "$WORKER" "${ARGS[@]}"
    RC=$?

    if [[ $RC -ne 0 ]]; then
        log "Vault $VAULT failed with status $RC"
        OVERALL_RC=$RC
    else
        log "Vault $VAULT complete"
    fi
done

log "All configured vault pulls complete (rc=$OVERALL_RC)"
exit $OVERALL_RC
