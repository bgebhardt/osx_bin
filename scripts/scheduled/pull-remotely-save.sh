#!/bin/bash

# Pull one Remotely Save S3-compatible bucket to a local folder with rclone.
#
# This is intentionally download-only:
#   remote Backblaze bucket -> local mirror
#
# Usage:
#   pull-remotely-save.sh --name NAME --bucket BUCKET --dest DIR [options]
#
# Required:
#   --name NAME       Identifier used for log/lock paths and default env file
#   --bucket BUCKET   Backblaze B2 bucket name used by Remotely Save
#   --dest DIR        Local destination root. Mirror lives at $DIR/current/;
#                     deleted/overwritten local files go to $DIR/_trash/<timestamp>/.
#
# Optional:
#   --endpoint URL    S3 endpoint (default: s3.us-west-001.backblazeb2.com)
#   --env-file FILE   Credential file (default: ~/.config/rclone/remotely-save-NAME.env)
#   --remote NAME     Temporary rclone remote name (default: remotely_save_NAME)
#   --trash-mode MODE What to do with local files that remote sync deletes or
#                     overwrites: keep or delete (default: keep)
#   --dry-run         Show what would change without writing local files
#   --verbose         Show detailed rclone file activity (also via VERBOSE=1)
#   -h, --help        Show this help
#
# Credential file options:
#   export REMOTELY_SAVE_KEY_ID="001..."
#   export REMOTELY_SAVE_APPLICATION_KEY="..."
#   export REMOTELY_SAVE_ENDPOINT="s3.us-west-001.backblazeb2.com"
#
# Or define rclone env config variables directly:
#   export RCLONE_CONFIG_REMOTELY_SAVE_PERSONAL_TYPE="s3"
#   export RCLONE_CONFIG_REMOTELY_SAVE_PERSONAL_PROVIDER="Other"
#   export RCLONE_CONFIG_REMOTELY_SAVE_PERSONAL_ACCESS_KEY_ID="001..."
#   export RCLONE_CONFIG_REMOTELY_SAVE_PERSONAL_SECRET_ACCESS_KEY="..."
#   export RCLONE_CONFIG_REMOTELY_SAVE_PERSONAL_ENDPOINT="https://s3.us-west-001.backblazeb2.com"
#
# Progress stats are logged every 15 seconds. Interactive terminal runs also
# stream log lines and rclone output to stdout.
#
# Logs:  /tmp/pull-remotely-save-<name>.log
# Lock:  /tmp/pull-remotely-save-<name>.lock.d

set -uo pipefail

usage() {
    awk 'NR >= 3 { if ($0 !~ /^#/) exit; sub(/^# ?/, ""); print }' "$0"
}

NAME=""
BUCKET=""
DEST_ROOT=""
ENDPOINT=""
ENV_FILE=""
REMOTE=""
DRY_RUN=0
TRASH_MODE="${TRASH_MODE:-keep}"
VERBOSE="${VERBOSE:-0}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)      NAME="$2"; shift 2 ;;
        --bucket)    BUCKET="$2"; shift 2 ;;
        --dest)      DEST_ROOT="$2"; shift 2 ;;
        --endpoint)  ENDPOINT="$2"; shift 2 ;;
        --env-file)  ENV_FILE="$2"; shift 2 ;;
        --remote)    REMOTE="$2"; shift 2 ;;
        --trash-mode) TRASH_MODE="$2"; shift 2 ;;
        --dry-run)   DRY_RUN=1; shift ;;
        --verbose|-v) VERBOSE=1; shift ;;
        -h|--help)   usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

missing=()
[[ -z "$NAME"   ]] && missing+=(--name)
[[ -z "$BUCKET" ]] && missing+=(--bucket)
[[ -z "$DEST_ROOT" ]] && missing+=(--dest)
if (( ${#missing[@]} > 0 )); then
    echo "Missing required: ${missing[*]}" >&2
    usage >&2
    exit 2
fi

if [[ -z "$ENDPOINT" ]]; then
    ENDPOINT="s3.us-west-001.backblazeb2.com"
fi
if [[ -z "$ENV_FILE" ]]; then
    ENV_FILE="$HOME/.config/rclone/remotely-save-${NAME}.env"
fi
if [[ -z "$REMOTE" ]]; then
    REMOTE="remotely_save_${NAME//-/_}"
fi

case "$TRASH_MODE" in
    keep|delete) ;;
    *) echo "Invalid --trash-mode: $TRASH_MODE (expected keep or delete)" >&2; exit 2 ;;
esac

LOG_FILE="/tmp/pull-remotely-save-${NAME}.log"
LOCK_DIR="/tmp/pull-remotely-save-${NAME}.lock.d"
MIRROR="$DEST_ROOT/current"
TRASH_ROOT="$DEST_ROOT/_trash"
RUN_TS="$(date '+%Y-%m-%d_%H-%M-%S')"

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

# LaunchAgents run with a minimal PATH, so probe the common Homebrew locations.
if [[ -x /opt/homebrew/bin/rclone ]]; then
    RCLONE=/opt/homebrew/bin/rclone
elif [[ -x /usr/local/bin/rclone ]]; then
    RCLONE=/usr/local/bin/rclone
elif RCLONE=$(command -v rclone 2>/dev/null); then
    :
else
    die "rclone not found at /opt/homebrew/bin/rclone, /usr/local/bin/rclone, or on PATH"
fi

if [[ ! -r "$ENV_FILE" ]]; then
    die "Credential file not found: $ENV_FILE"
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

# Refuse destination values that look like rclone remotes. The destination must
# be local so this job can never become a cloud-to-cloud or local-to-cloud sync.
if [[ "$DEST_ROOT" == *:* ]]; then
    die "Destination must be a local path, got: $DEST_ROOT"
fi

if [[ "$TRASH_MODE" == "keep" ]]; then
    mkdir -p "$MIRROR" "$TRASH_ROOT" || die "Could not create destination: $DEST_ROOT"
else
    mkdir -p "$MIRROR" || die "Could not create destination: $DEST_ROOT"
fi

# Build rclone config in environment only, unless the env file already provided
# explicit RCLONE_CONFIG_<REMOTE>_* variables.
REMOTE_ENV_PREFIX="$(printf '%s' "$REMOTE" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9]/_/g')"
TYPE_VAR="RCLONE_CONFIG_${REMOTE_ENV_PREFIX}_TYPE"
PROVIDER_VAR="RCLONE_CONFIG_${REMOTE_ENV_PREFIX}_PROVIDER"
ACCESS_KEY_VAR="RCLONE_CONFIG_${REMOTE_ENV_PREFIX}_ACCESS_KEY_ID"
SECRET_KEY_VAR="RCLONE_CONFIG_${REMOTE_ENV_PREFIX}_SECRET_ACCESS_KEY"
ENDPOINT_VAR="RCLONE_CONFIG_${REMOTE_ENV_PREFIX}_ENDPOINT"
NO_CHECK_BUCKET_VAR="RCLONE_CONFIG_${REMOTE_ENV_PREFIX}_NO_CHECK_BUCKET"

if [[ -z "${!TYPE_VAR:-}" ]]; then
    if [[ -z "${REMOTELY_SAVE_KEY_ID:-}" || -z "${REMOTELY_SAVE_APPLICATION_KEY:-}" ]]; then
        die "Set REMOTELY_SAVE_KEY_ID and REMOTELY_SAVE_APPLICATION_KEY in $ENV_FILE"
    fi

    export "$TYPE_VAR=s3"
    export "$PROVIDER_VAR=Other"
    export "$ACCESS_KEY_VAR=$REMOTELY_SAVE_KEY_ID"
    export "$SECRET_KEY_VAR=$REMOTELY_SAVE_APPLICATION_KEY"
    export "$ENDPOINT_VAR=https://${REMOTELY_SAVE_ENDPOINT:-$ENDPOINT}"
    export "$NO_CHECK_BUCKET_VAR=true"
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

RCLONE_OPTS=(
    sync
    "${REMOTE}:${BUCKET}"
    "$MIRROR"
    --fast-list
    --links
    --exclude ".DS_Store"
    --exclude "._*"
    --exclude "_trash/**"
)

if [[ "$TRASH_MODE" == "keep" ]]; then
    RCLONE_OPTS+=(--backup-dir "$TRASH_ROOT/$RUN_TS")
fi

if [[ "$DRY_RUN" != "0" ]]; then
    RCLONE_OPTS+=(--dry-run)
fi

RCLONE_OPTS+=(--stats 15s --stats-log-level NOTICE)

if [[ "$VERBOSE" != "0" || "$DRY_RUN" != "0" ]]; then
    RCLONE_OPTS+=(-v)
fi

log "Starting pull: ${REMOTE}:${BUCKET} -> $MIRROR (trash-mode=$TRASH_MODE)"
if [[ -t 1 ]]; then
    "$RCLONE" "${RCLONE_OPTS[@]}" 2>&1 | tee -a "$LOG_FILE"
    RC=${PIPESTATUS[0]}
else
    "$RCLONE" "${RCLONE_OPTS[@]}" >> "$LOG_FILE" 2>&1
    RC=$?
fi

if [[ $RC -ne 0 ]]; then
    log "rclone sync exited with status $RC"
fi

if [[ "$TRASH_MODE" == "keep" ]] && [[ -d "$TRASH_ROOT/$RUN_TS" ]] && [[ -z "$(ls -A "$TRASH_ROOT/$RUN_TS" 2>/dev/null)" ]]; then
    rmdir "$TRASH_ROOT/$RUN_TS" 2>/dev/null
fi

log "Pull complete (rclone rc=$RC)"
exit $RC
