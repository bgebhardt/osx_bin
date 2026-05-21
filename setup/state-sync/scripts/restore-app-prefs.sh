#!/bin/bash
#
# restore-app-prefs.sh
# Restore application preferences from a snapshot (mirror of capture-app-prefs.sh).
# Reads plist files from <snapshot_dir>/app-plists/ and runs `defaults import`
# for each domain.
#
# Usage:
#   restore-app-prefs.sh [--dry-run] [--all] [--apps DOMAIN,DOMAIN,...] [snapshot_dir]
#
# Flags:
#   --dry-run    Print what would happen without importing
#   --all        Don't prompt before each import (default: prompt per domain)
#   --apps       Comma-separated list of domains to restore; others skipped

set -euo pipefail

DRY_RUN=false
ALL=false
APPS_FILTER=""
INPUT_SNAPSHOT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --all)     ALL=true; shift ;;
        --apps)    APPS_FILTER="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) INPUT_SNAPSHOT="$1"; shift ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$(dirname "$SCRIPT_DIR")/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

if [[ -z "$INPUT_SNAPSHOT" ]]; then
    SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$HOME/bin/setup/state-sync/snapshots")
    INPUT_SNAPSHOT=$(find "$SNAPSHOT_BASE" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)
fi

if [[ -z "$INPUT_SNAPSHOT" || ! -d "$INPUT_SNAPSHOT" ]]; then
    echo "Error: snapshot dir not found: '$INPUT_SNAPSHOT'" >&2
    exit 1
fi

PLIST_DIR="$INPUT_SNAPSHOT/app-plists"
if [[ ! -d "$PLIST_DIR" ]]; then
    echo "Error: no plists at $PLIST_DIR (run capture-app-prefs.sh first)" >&2
    exit 1
fi

echo "Snapshot:    $INPUT_SNAPSHOT"
echo "Plist dir:   $PLIST_DIR"
[[ "$DRY_RUN" == "true" ]] && echo "Mode:        DRY-RUN (no changes)"

# Build allowlist if --apps was passed
declare -a ALLOW_DOMAINS=()
if [[ -n "$APPS_FILTER" ]]; then
    IFS=',' read -ra ALLOW_DOMAINS <<< "$APPS_FILTER"
fi

is_allowed() {
    local domain="$1"
    [[ ${#ALLOW_DOMAINS[@]} -eq 0 ]] && return 0
    for d in "${ALLOW_DOMAINS[@]}"; do
        [[ "$d" == "$domain" ]] && return 0
    done
    return 1
}

imported=0
skipped=0
failed=0

shopt -s nullglob
for plist in "$PLIST_DIR"/*.plist; do
    domain=$(basename "$plist" .plist)

    if ! is_allowed "$domain"; then
        echo "  SKIP   $domain (not in --apps filter)"
        skipped=$((skipped + 1))
        continue
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        size=$(wc -c < "$plist" | tr -d ' ')
        echo "  DRY    $domain  ($size bytes)"
        imported=$((imported + 1))
        continue
    fi

    proceed=true
    if [[ "$ALL" != "true" ]]; then
        existing=""
        if defaults read "$domain" &>/dev/null; then
            existing=" (overwriting existing prefs)"
        fi
        read -r -p "Import $domain$existing? [y/N] " ans
        case "$ans" in
            y|Y|yes|YES) ;;
            *) proceed=false ;;
        esac
    fi

    if [[ "$proceed" == "false" ]]; then
        echo "  SKIP   $domain (user declined)"
        skipped=$((skipped + 1))
        continue
    fi

    if defaults import "$domain" "$plist"; then
        echo "  OK     $domain"
        imported=$((imported + 1))
    else
        echo "  FAIL   $domain"
        failed=$((failed + 1))
    fi
done
shopt -u nullglob

echo ""
echo "Imported: $imported"
echo "Skipped:  $skipped"
echo "Failed:   $failed"
[[ "$failed" -gt 0 ]] && exit 1
exit 0
