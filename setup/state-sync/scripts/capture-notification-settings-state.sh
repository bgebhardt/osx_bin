#!/bin/bash
#
# capture-notification-settings-state.sh
# Captures whatever notification-related state is readable on this macOS.
#
# BACKGROUND (2026):
#   The legacy ~/Library/Preferences/com.apple.ncprefs.plist was removed in
#   newer macOS (Sequoia/Tahoe). Per-app notification settings now live in
#   the sandboxed usernotificationsd daemon and are not directly readable
#   from user-space scripts. TCC.db has the permission grant/deny info but
#   reading it requires Full Disk Access granted to Terminal (a manual
#   user step), and even then it only records allowed/denied, not the
#   detailed style settings (banner/alert/sound/badge/lock-screen).
#
#   This script captures what IS accessible, documents the limitations,
#   and never fails the baseline.
#
# Output: notification-settings.json + notification-settings.txt
# Usage: ./capture-notification-settings-state.sh [output_dir]

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$(dirname "$SCRIPT_DIR")/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

if [[ -n "${1:-}" ]]; then
    OUTPUT_DIR="$1"
else
    SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$HOME/bin/setup/state-sync/snapshots")
    OUTPUT_DIR="$SNAPSHOT_BASE/$(date +%Y-%m-%d-%H%M%S)"
fi
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/notification-settings.json"
SUMMARY_FILE="$OUTPUT_DIR/notification-settings.txt"

echo "Capturing notification settings state..."

# ---- Probes ----
LEGACY_PLIST="$HOME/Library/Preferences/com.apple.ncprefs.plist"
USERNOTIFD_PLIST="$HOME/Library/Preferences/com.apple.usernotificationsd.plist"
USERNOTIFKIT_PLIST="$HOME/Library/Preferences/com.apple.usernotificationskit.plist"
USER_TCC_DB="$HOME/Library/Application Support/com.apple.TCC/TCC.db"
SYSTEM_TCC_DB="/Library/Application Support/com.apple.TCC/TCC.db"

MACOS_VER=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
MACOS_BUILD=$(sw_vers -buildVersion 2>/dev/null || echo "unknown")

LEGACY_AVAILABLE=false
LEGACY_APPS=()
if [[ -f "$LEGACY_PLIST" ]] && /usr/libexec/PlistBuddy -c "Print :apps" "$LEGACY_PLIST" &>/dev/null; then
    LEGACY_AVAILABLE=true
    # Parse legacy plist (pre-Sequoia macOS)
    NUM_APPS=$(/usr/libexec/PlistBuddy -c "Print :apps" "$LEGACY_PLIST" 2>/dev/null | grep -c "Dict" || echo 0)
    for ((i=0; i<NUM_APPS; i++)); do
        BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:bundle-id" "$LEGACY_PLIST" 2>/dev/null || echo "")
        FLAGS=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:flags" "$LEGACY_PLIST" 2>/dev/null || echo "")
        [[ -n "$BUNDLE_ID" ]] && LEGACY_APPS+=("$BUNDLE_ID:$FLAGS")
    done
fi

# ---- TCC notification permissions (kTCCServiceUserNotifications) ----
# Only readable if Terminal has Full Disk Access. Try both user and system DBs.
TCC_APPS_NDJSON=$(mktemp)
TCC_READABLE=false
TCC_SOURCE=""
for db in "$USER_TCC_DB" "$SYSTEM_TCC_DB"; do
    [[ -f "$db" ]] || continue
    # The 'access' table on modern macOS has columns including:
    # service, client, client_type, auth_value, auth_reason, auth_version, ...
    # auth_value: 0=denied, 2=allowed (varies by version)
    out=$(sqlite3 "$db" \
        "SELECT client, auth_value FROM access WHERE service = 'kTCCServiceUserNotifications';" \
        2>/dev/null || true)
    if [[ -n "$out" ]]; then
        TCC_READABLE=true
        TCC_SOURCE="$db"
        while IFS='|' read -r client auth; do
            [[ -z "$client" ]] && continue
            case "$auth" in
                0) status="denied"  ;;
                2) status="allowed" ;;
                *) status="unknown" ;;
            esac
            jq -nc --arg c "$client" --arg s "$status" --argjson v "${auth:-0}" \
                '{client: $c, auth_status: $s, auth_value: $v}' >> "$TCC_APPS_NDJSON"
        done <<<"$out"
        break
    fi
done

TCC_APPS_JSON=$(jq -s '.' "$TCC_APPS_NDJSON" 2>/dev/null || echo "[]")
TCC_COUNT=$(jq 'length' <<<"$TCC_APPS_JSON" 2>/dev/null || echo 0)
rm -f "$TCC_APPS_NDJSON"

# ---- Global notification settings ----
REMOTE_NOTIF_ENABLED=$(defaults read com.apple.usernotificationsd RemoteNotifications.isEnabled 2>/dev/null || echo "unknown")

# ---- Build JSON output ----
if ! command -v jq &>/dev/null; then
    echo "Error: jq is required." >&2
    exit 1
fi

jq -n \
    --arg capture_date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg hostname "$(hostname)" \
    --arg user "$USER" \
    --arg macos_ver "$MACOS_VER" \
    --arg macos_build "$MACOS_BUILD" \
    --argjson legacy_available "$LEGACY_AVAILABLE" \
    --argjson tcc_readable "$TCC_READABLE" \
    --arg tcc_source "$TCC_SOURCE" \
    --argjson tcc_apps "$TCC_APPS_JSON" \
    --arg remote_notif_enabled "$REMOTE_NOTIF_ENABLED" \
    '{
      capture_date: $capture_date,
      hostname: $hostname,
      user: $user,
      macos: {version: $macos_ver, build: $macos_build},
      capture_status: {
        legacy_plist_available: $legacy_available,
        tcc_db_readable: $tcc_readable,
        tcc_source: $tcc_source,
        note: (
          if $legacy_available then "Legacy plist found — per-app settings captured."
          elif $tcc_readable then "TCC db readable — per-app allow/deny captured (Terminal has Full Disk Access)."
          else "Neither legacy plist nor TCC db readable. Grant Terminal Full Disk Access (System Settings → Privacy & Security → Full Disk Access) to capture per-app notification permissions on this macOS version."
          end
        )
      },
      tcc_notification_permissions: $tcc_apps,
      global_settings: {
        remote_notifications_enabled: $remote_notif_enabled
      }
    }' > "$OUTPUT_FILE"

# ---- Build human-readable summary ----
{
    echo "========================================"
    echo "Notification Settings State Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo "macOS: $MACOS_VER ($MACOS_BUILD)"
    echo ""
    echo "Capture status:"
    echo "  Legacy plist available: $LEGACY_AVAILABLE"
    echo "  TCC db readable:        $TCC_READABLE"
    [[ -n "$TCC_SOURCE" ]] && echo "  TCC source:             $TCC_SOURCE"
    echo ""

    if [[ "$LEGACY_AVAILABLE" == "true" ]]; then
        echo "========================================"
        echo "Per-app settings (from legacy plist)"
        echo "========================================"
        printf '%s\n' "${LEGACY_APPS[@]}" | awk -F: 'BEGIN{printf "%-60s %s\n", "BUNDLE ID", "FLAGS"} {printf "%-60s %s\n", $1, $2}'
        echo ""
    fi

    if [[ "$TCC_READABLE" == "true" ]]; then
        echo "========================================"
        echo "TCC notification permissions ($TCC_COUNT apps)"
        echo "========================================"
        echo "Source: $TCC_SOURCE"
        echo ""
        jq -r '.tcc_notification_permissions[] | "\(.auth_status)\t\(.client)"' "$OUTPUT_FILE" \
            | sort | awk -F'\t' 'BEGIN{printf "%-9s %s\n", "STATUS", "CLIENT"} {printf "%-9s %s\n", $1, $2}'
        echo ""
    fi

    if [[ "$LEGACY_AVAILABLE" == "false" ]] && [[ "$TCC_READABLE" == "false" ]]; then
        echo "========================================"
        echo "Per-app settings NOT CAPTURED"
        echo "========================================"
        echo "On macOS $MACOS_VER:"
        echo "  - Legacy ~/Library/Preferences/com.apple.ncprefs.plist no longer exists"
        echo "    (Apple moved per-app notification settings into the sandboxed"
        echo "    usernotificationsd daemon — not accessible from user scripts.)"
        echo "  - TCC.db is also not readable by this Terminal."
        echo ""
        echo "To capture per-app notification permissions on modern macOS:"
        echo "  1. Open: System Settings → Privacy & Security → Full Disk Access"
        echo "  2. Click '+' and add: $(command -v bash) (or Terminal.app / iTerm.app)"
        echo "  3. Re-run create-baseline.sh"
        echo ""
        echo "Note: even with TCC access, the captured info is per-app allow/deny only."
        echo "Detailed settings (banner style, sounds, badges, lock screen) require"
        echo "manual re-configuration on the target Mac."
        echo ""
    fi

    echo "========================================"
    echo "Global settings"
    echo "========================================"
    echo "RemoteNotifications.isEnabled: $REMOTE_NOTIF_ENABLED"
} > "$SUMMARY_FILE"

echo ""
echo "Notification settings captured successfully!"
echo "JSON: $OUTPUT_FILE"
echo "Summary: $SUMMARY_FILE"
echo ""
head -30 "$SUMMARY_FILE"
