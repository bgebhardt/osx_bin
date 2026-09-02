#!/bin/bash

# Push all configured Obsidian Remotely Save outbox folders up to their
# Backblaze B2 buckets.
#
# This is the upload counterpart to pull-obsidian-remotely-save.sh, and reads
# the same env file (vault list + per-vault Backblaze S3 credentials). For
# each vault, if a local outbox folder exists and is non-empty, its contents
# are copied (never synced/deleted) up to that vault's bucket root by calling
# push-remotely-save.sh once per vault.
#
# A vault only needs an outbox if something (e.g. Hermes) writes into it.
# Vaults with no outbox folder, or an empty one, are skipped without error.
#
# Credentials: ~/.config/rclone/obsidian-remotely-save.env (same file the
#              pull job uses)
# Example:     ~/bin/scripts/scheduled/obsidian-remotely-save.env.example
# Local outbox root: ~/Obsidian Remotely Save Outbox/<vault>/
# Logs:        /tmp/push-obsidian-remotely-save.log
#
# Usage:
#   push-obsidian-remotely-save.sh [--vault NAME] [--dry-run] [--verbose]
#
#   --vault NAME   Only push this one vault instead of all configured vaults.
#
# Interactive terminal runs stream progress to stdout. Per-vault rclone stats
# are also written to /tmp/push-remotely-save-<vault>.log every 15 seconds.
#
# This script and push-remotely-save.sh only ever add or overwrite objects in
# the bucket (rclone copy, never sync, no --delete-* flags) — they can never
# remove existing vault content, remotely or locally.

set -uo pipefail

NAME="obsidian-remotely-save"
ENV_FILE="$HOME/.config/rclone/obsidian-remotely-save.env"
DEFAULT_OUTBOX_ROOT="$HOME/Obsidian Remotely Save Outbox"
OUTBOX_ROOT_ARG=""
OUTBOX_ROOT="$DEFAULT_OUTBOX_ROOT"
LOG_FILE="/tmp/push-${NAME}.log"
LOCK_DIR="/tmp/push-${NAME}.lock.d"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKER="$SCRIPT_DIR/push-remotely-save.sh"
DRY_RUN=0
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
        --outbox-root) OUTBOX_ROOT_ARG="$2"; shift 2 ;;
        --vault)       VAULT_FILTER="$2"; shift 2 ;;
        --dry-run)     DRY_RUN=1; shift ;;
        --verbose|-v)  VERBOSE=1; shift ;;
        -h|--help)     usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

if [[ ! -x "$WORKER" ]]; then
    die "Worker script not executable: $WORKER"
fi

if [[ ! -f "$ENV_FILE" ]]; then
    die "Credential file not found: $ENV_FILE"
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

OUTBOX_ROOT="${OUTBOX_ROOT_ARG:-${OBSIDIAN_REMOTELY_SAVE_OUTBOX_ROOT:-$DEFAULT_OUTBOX_ROOT}}"

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

if [[ "$OUTBOX_ROOT" == *:* ]]; then
    die "Outbox root must be a local path, got: $OUTBOX_ROOT"
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
log "Starting configured vault pushes: $OBSIDIAN_REMOTELY_SAVE_VAULTS (outbox-root=$OUTBOX_ROOT)"

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

    VAULT_OUTBOX="$OUTBOX_ROOT/$VAULT"

    if [[ ! -d "$VAULT_OUTBOX" ]] || [[ -z "$(find "$VAULT_OUTBOX" -mindepth 1 -not -name ".DS_Store" -print -quit 2>/dev/null)" ]]; then
        log "Skipping $VAULT: no outbox folder or nothing to push ($VAULT_OUTBOX)"
        continue
    fi

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
        --source "$VAULT_OUTBOX"
    )

    if [[ "$DRY_RUN" != "0" ]]; then
        ARGS+=(--dry-run)
    fi
    if [[ "$VERBOSE" != "0" ]]; then
        ARGS+=(--verbose)
    fi

    log "Pushing vault $VAULT to bucket $BUCKET"
    REMOTELY_SAVE_KEY_ID="$KEY_ID" \
        REMOTELY_SAVE_APPLICATION_KEY="$APPLICATION_KEY" \
        REMOTELY_SAVE_ENDPOINT="$ENDPOINT" \
        "$WORKER" "${ARGS[@]}"
    RC=$?

    if [[ $RC -ne 0 ]]; then
        log "Vault $VAULT push failed with status $RC"
        OVERALL_RC=$RC
    else
        log "Vault $VAULT push complete"
    fi
done

log "All configured vault pushes complete (rc=$OVERALL_RC)"
exit $OVERALL_RC
