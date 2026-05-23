#!/bin/bash
#
# push-to-mac.sh
# Generates fresh tier/install data on this Mac, builds a transfer bundle, and
# rsyncs it over SSH to a target Mac. Optionally kicks off apply-on-remote.sh
# interactively over SSH.
#
# Usage:
#   push-to-mac.sh <host> [--tier essentials|regular|all]
#                         [--include configs|prefs|defaults|all]
#                         [--dry-run] [--no-fresh-capture]
#                         [--no-run] [--remote-dir PATH] [--user USER]
#
# Defaults:
#   --tier essentials
#   --include (none) — only install scripts are shipped
#   remote dir: ~/state-sync-incoming/ (i.e. on the target host)
#
# Common patterns:
#   Dry-run preview:    push-to-mac.sh newmac.local --dry-run
#   Full transfer:      push-to-mac.sh newmac.local --tier regular --include all
#   Skip auto-apply:    push-to-mac.sh newmac.local --no-run

set -euo pipefail

HOST=""
TIER="essentials"
INCLUDE=""
DRY_RUN=false
NO_FRESH=false
NO_RUN=false
# Relative path → resolved against the remote user's home by both ssh and rsync.
# Avoids the "$HOME isn't expanded by rsync's remote spec" gotcha.
REMOTE_DIR='state-sync-incoming'
REMOTE_USER=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tier) TIER="$2"; shift 2 ;;
        --include) INCLUDE="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --no-fresh-capture) NO_FRESH=true; shift ;;
        --no-run) NO_RUN=true; shift ;;
        --remote-dir) REMOTE_DIR="$2"; shift 2 ;;
        --user) REMOTE_USER="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            if [[ -z "$HOST" ]]; then HOST="$1"; else echo "Unknown arg: $1" >&2; exit 1; fi
            shift
            ;;
    esac
done

if [[ -z "$HOST" ]]; then
    echo "Error: target host required" >&2
    echo "Usage: $(basename "$0") <host> [options]" >&2
    exit 1
fi

case "$TIER" in
    essentials|regular|all) ;;
    *) echo "Error: --tier must be essentials, regular, or all" >&2; exit 1 ;;
esac

INCLUDE_CONFIGS=false
INCLUDE_PREFS=false
INCLUDE_DEFAULTS=false
case "$INCLUDE" in
    "") ;;
    all)      INCLUDE_CONFIGS=true; INCLUDE_PREFS=true; INCLUDE_DEFAULTS=true ;;
    *)
        IFS=',' read -ra includes <<< "$INCLUDE"
        for i in "${includes[@]}"; do
            case "$i" in
                configs)  INCLUDE_CONFIGS=true ;;
                prefs)    INCLUDE_PREFS=true ;;
                defaults) INCLUDE_DEFAULTS=true ;;
                *) echo "Error: unknown --include item: $i" >&2; exit 1 ;;
            esac
        done
        ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$(dirname "$SCRIPT_DIR")/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi
SETUP_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SSH_TARGET="$HOST"
[[ -n "$REMOTE_USER" ]] && SSH_TARGET="$REMOTE_USER@$HOST"

# ---- SSH connection multiplexing ----
# Opens a single master connection (one password prompt if key auth isn't set
# up) and reuses it for every subsequent ssh/rsync call. ControlPersist keeps
# the socket alive for 10 minutes after the script exits.
SSH_CTL_DIR=$(mktemp -d "/tmp/state-sync-ssh-XXXXXX")
SSH_CTL="$SSH_CTL_DIR/ctl-%h-%p-%r"
SSH_OPTS=(-o "ControlMaster=auto" -o "ControlPath=$SSH_CTL" -o "ControlPersist=10m")
# rsync picks up RSYNC_RSH from the environment
export RSYNC_RSH="ssh -o ControlMaster=auto -o ControlPath=$SSH_CTL -o ControlPersist=10m"

cleanup_ssh() {
    # Close the master and remove the control dir
    if [[ -n "${SSH_TARGET:-}" ]] && [[ -e "${SSH_CTL_DIR:-}" ]]; then
        ssh -o "ControlPath=$SSH_CTL" -O exit "$SSH_TARGET" 2>/dev/null || true
    fi
    [[ -n "${SSH_CTL_DIR:-}" ]] && rm -rf "$SSH_CTL_DIR"
}
trap cleanup_ssh EXIT

echo "========================================"
echo "Push to Mac: $SSH_TARGET"
echo "========================================"
echo "Tier:             $TIER"
echo "Include configs:  $INCLUDE_CONFIGS"
echo "Include prefs:    $INCLUDE_PREFS"
echo "Include defaults: $INCLUDE_DEFAULTS"
echo "Remote dir:       $REMOTE_DIR (on target)"
[[ "$DRY_RUN" == "true" ]] && echo "Mode:             DRY-RUN"
echo ""

# ---- Verify SSH connectivity ----
# Drops BatchMode so SSH can fall back to password auth if no key is set up.
# This is also the call that opens the multiplex master, so subsequent
# ssh/rsync calls reuse the same authenticated socket.
echo "--- Checking SSH connectivity (will prompt for password if no key auth) ---"
if ! ssh "${SSH_OPTS[@]}" -o ConnectTimeout=10 "$SSH_TARGET" "echo ok" >/dev/null; then
    echo "Error: cannot SSH to $SSH_TARGET" >&2
    echo "Hint: try 'ssh $SSH_TARGET' manually first to diagnose." >&2
    exit 1
fi
echo "  SSH OK."
echo ""

# ---- Stage A: Refresh local capture and tier data ----
if [[ "$NO_FRESH" != "true" ]]; then
    echo "--- Refreshing local snapshot (capture → tiers → install scripts) ---"

    SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$HOME/bin/setup/state-sync/snapshots")
    SNAPSHOT_DIR_NEW="$SNAPSHOT_BASE/$(date +%Y-%m-%d-%H%M%S)"
    mkdir -p "$SNAPSHOT_DIR_NEW"
    echo "  Snapshot: $SNAPSHOT_DIR_NEW"

    "$SCRIPT_DIR/capture-app-usage.sh" "$SNAPSHOT_DIR_NEW" >/dev/null
    if [[ "$INCLUDE_PREFS" == "true" ]] && [[ -f "$SCRIPT_DIR/capture-app-prefs.sh" ]]; then
        "$SCRIPT_DIR/capture-app-prefs.sh" "$SNAPSHOT_DIR_NEW" >/dev/null
    fi
    "$SCRIPT_DIR/generate-app-tiers.sh" "$SNAPSHOT_DIR_NEW" >/dev/null
    "$SCRIPT_DIR/generate-install-scripts.sh" --tier "$TIER" "$SNAPSHOT_DIR_NEW" >/dev/null

    SNAPSHOT_DIR="$SNAPSHOT_DIR_NEW"
else
    SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$HOME/bin/setup/state-sync/snapshots")
    SNAPSHOT_DIR=$(find "$SNAPSHOT_BASE" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)
    if [[ -z "$SNAPSHOT_DIR" ]]; then
        echo "Error: no existing snapshot. Drop --no-fresh-capture or run create-baseline.sh first." >&2
        exit 1
    fi
    echo "  Using existing snapshot: $SNAPSHOT_DIR"
fi
echo ""

INSTALL_SUBDIR="$SNAPSHOT_DIR/tiers/install"
if [[ ! -d "$INSTALL_SUBDIR" ]]; then
    echo "Error: install scripts dir not found: $INSTALL_SUBDIR" >&2
    exit 1
fi

# ---- Stage B: Build transfer bundle ----
echo "--- Building bundle ---"
BUNDLE_DIR=$(mktemp -d "/tmp/state-sync-bundle-XXXXXX")
echo "  Local bundle: $BUNDLE_DIR"

mkdir -p "$BUNDLE_DIR/install"
# Install scripts for this tier (and only this tier)
cp "$INSTALL_SUBDIR/install-${TIER}-"* "$BUNDLE_DIR/install/" 2>/dev/null || true

# Scripts the apply phase will need.
# apply-on-remote.sh lives under templates/ since it's the script that gets
# shipped to and runs on the target Mac (easier to review separately from the
# orchestration code in scripts/).
TEMPLATES_DIR="$(dirname "$SCRIPT_DIR")/templates"
cp "$TEMPLATES_DIR/apply-on-remote.sh" "$BUNDLE_DIR/"
cp "$SCRIPT_DIR/restore-app-prefs.sh" "$BUNDLE_DIR/"
cp "$SCRIPT_DIR/lib-classify-app.sh" "$BUNDLE_DIR/"
chmod +x "$BUNDLE_DIR/apply-on-remote.sh"

if [[ "$INCLUDE_CONFIGS" == "true" ]]; then
    if [[ -d "$SETUP_ROOT/configs" ]]; then
        cp -r "$SETUP_ROOT/configs" "$BUNDLE_DIR/configs"
        echo "  + configs/"
    fi
fi

if [[ "$INCLUDE_DEFAULTS" == "true" ]]; then
    if [[ -f "$SETUP_ROOT/macOS/mac-defaults.sh" ]]; then
        cp "$SETUP_ROOT/macOS/mac-defaults.sh" "$BUNDLE_DIR/mac-defaults.sh"
        echo "  + mac-defaults.sh"
    fi
fi

if [[ "$INCLUDE_PREFS" == "true" ]]; then
    if [[ -d "$SNAPSHOT_DIR/app-plists" ]]; then
        cp -r "$SNAPSHOT_DIR/app-plists" "$BUNDLE_DIR/app-plists"
        echo "  + app-plists/ ($(find "$BUNDLE_DIR/app-plists" -name '*.plist' | wc -l | tr -d ' ') files)"
    else
        echo "  WARN: --include prefs requested but no plists found in snapshot"
    fi
fi

# MANIFEST
{
    echo "State-Sync Transfer Bundle"
    echo "=========================="
    echo "Source host:      $(hostname)"
    echo "Source user:      $USER"
    echo "Generated at:     $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Source snapshot:  $SNAPSHOT_DIR"
    echo "Tier:             $TIER"
    echo "Include configs:  $INCLUDE_CONFIGS"
    echo "Include prefs:    $INCLUDE_PREFS"
    echo "Include defaults: $INCLUDE_DEFAULTS"
    echo ""
    echo "Contents:"
    find "$BUNDLE_DIR" -mindepth 1 -maxdepth 2 -print | sed "s|^$BUNDLE_DIR/||" | sort
} > "$BUNDLE_DIR/MANIFEST.txt"
chmod +x "$BUNDLE_DIR"/*.sh "$BUNDLE_DIR/install"/*.sh 2>/dev/null || true
echo ""

# ---- Stage C: Safety scan for secrets ----
echo "--- Secret scan ---"
SUSPECT=$(find "$BUNDLE_DIR" -type f \( \
    -iname '*token*' -o -iname '*secret*' -o -iname '*.key' -o \
    -iname '.env*' -o -iname '*keychain*' -o -iname 'id_rsa*' -o \
    -iname 'id_ed25519*' -o -iname '.ssh*' \) 2>/dev/null || true)
if [[ -n "$SUSPECT" ]]; then
    echo "  WARNING: suspicious files in bundle:"
    echo "$SUSPECT" | sed 's/^/    /'
    if ! [[ "$DRY_RUN" == "true" ]]; then
        read -r -p "Continue anyway? [y/N] " ans
        case "$ans" in y|Y|yes|YES) ;; *) echo "Aborting."; exit 1 ;; esac
    fi
else
    echo "  Clean."
fi
echo ""

# ---- Stage D: Rsync ----
RSYNC_EXCLUDES=(
    --exclude='*.key' --exclude='*token*' --exclude='*secret*'
    --exclude='.ssh*' --exclude='.env*' --exclude='*keychain*'
    --exclude='id_rsa*' --exclude='id_ed25519*'
)

# Ensure remote dir exists (reuses the multiplex master, no extra password prompt)
ssh "${SSH_OPTS[@]}" "$SSH_TARGET" "mkdir -p ${REMOTE_DIR}"

echo "--- rsync dry-run preview ---"
rsync -avz --dry-run "${RSYNC_EXCLUDES[@]}" "$BUNDLE_DIR/" "$SSH_TARGET:$REMOTE_DIR/" \
    | tail -30
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    echo "Dry-run complete. Bundle kept at: $BUNDLE_DIR"
    exit 0
fi

read -r -p "Proceed with rsync transfer? [y/N] " ans
case "$ans" in y|Y|yes|YES) ;; *) echo "Aborted."; exit 1 ;; esac

echo "--- rsync transfer ---"
rsync -avz "${RSYNC_EXCLUDES[@]}" "$BUNDLE_DIR/" "$SSH_TARGET:$REMOTE_DIR/"
echo ""

# ---- Stage E: Trigger apply on remote ----
if [[ "$NO_RUN" == "true" ]]; then
    echo "Transfer complete. To apply, SSH to $SSH_TARGET and run:"
    echo "  bash ~/${REMOTE_DIR}/apply-on-remote.sh"
    exit 0
fi

read -r -p "Run apply-on-remote.sh on $SSH_TARGET now (interactive)? [y/N] " ans
case "$ans" in
    y|Y|yes|YES)
        echo "--- Running apply-on-remote.sh on $SSH_TARGET ---"
        ssh "${SSH_OPTS[@]}" -t "$SSH_TARGET" "bash ~/${REMOTE_DIR}/apply-on-remote.sh"
        ;;
    *)
        echo "Skipped. Bundle is staged at: $SSH_TARGET:$REMOTE_DIR"
        ;;
esac
