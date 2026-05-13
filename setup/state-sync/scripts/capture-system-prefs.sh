#!/bin/bash
#
# capture-system-prefs.sh
# Captures macOS system preferences
#
# Output: JSON file with key system settings
# Usage: ./capture-system-prefs.sh [output_dir]

set -euo pipefail

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$(dirname "$SCRIPT_DIR")/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

# Default output directory (use config if no argument provided)
if [[ -n "${1:-}" ]]; then
    OUTPUT_DIR="$1"
else
    SNAPSHOT_BASE=$(get_snapshot_dir 2>/dev/null || echo "$HOME/bin/setup/state-sync/snapshots")
    OUTPUT_DIR="$SNAPSHOT_BASE/$(date +%Y-%m-%d-%H%M%S)"
fi
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/system-prefs.json"
SUMMARY_FILE="$OUTPUT_DIR/system-prefs.txt"
PLIST_DIR="$OUTPUT_DIR/plists"
mkdir -p "$PLIST_DIR"

echo "Capturing system preferences state..."
echo "Output directory: $OUTPUT_DIR"

# Key system preference domains to capture
SYSTEM_DOMAINS=(
    "com.apple.dock"
    "com.apple.finder"
    "com.apple.screensaver"
    "com.apple.screencapture"
    "com.apple.trackpad"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad"
    "com.apple.AppleMultitouchTrackpad"
    "com.apple.keyboard"
    "com.apple.menuextra.clock"
    "com.apple.systempreferences"
    "com.apple.desktopservices"
    "NSGlobalDomain"
)

# Start building JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"capture_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$OUTPUT_FILE"
echo "  \"hostname\": \"$(hostname)\"," >> "$OUTPUT_FILE"
echo "  \"user\": \"$USER\"," >> "$OUTPUT_FILE"
echo "  \"os_version\": \"$(sw_vers -productVersion)\"," >> "$OUTPUT_FILE"
echo "  \"build_version\": \"$(sw_vers -buildVersion)\"," >> "$OUTPUT_FILE"
echo "  \"preferences\": {" >> "$OUTPUT_FILE"

first_domain=true
for domain in "${SYSTEM_DOMAINS[@]}"; do
    # Export plist to file
    defaults export "$domain" "$PLIST_DIR/$domain.plist" 2>/dev/null || continue

    if [[ "$first_domain" == "true" ]]; then
        first_domain=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi

    echo -n "    \"$domain\": \"exported to plists/$domain.plist\"" >> "$OUTPUT_FILE"
done

echo "" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# Capture some specific important settings
echo "  \"key_settings\": {" >> "$OUTPUT_FILE"

# Dock settings
DOCK_AUTOHIDE=$(defaults read com.apple.dock autohide 2>/dev/null || echo "null")
DOCK_ORIENTATION=$(defaults read com.apple.dock orientation 2>/dev/null || echo "null")
DOCK_TILESIZE=$(defaults read com.apple.dock tilesize 2>/dev/null || echo "null")

echo "    \"dock\": {" >> "$OUTPUT_FILE"
echo "      \"autohide\": $DOCK_AUTOHIDE," >> "$OUTPUT_FILE"
echo "      \"orientation\": \"$DOCK_ORIENTATION\"," >> "$OUTPUT_FILE"
echo "      \"tilesize\": $DOCK_TILESIZE" >> "$OUTPUT_FILE"
echo "    }," >> "$OUTPUT_FILE"

# Finder settings
SHOW_HIDDEN=$(defaults read com.apple.finder AppleShowAllFiles 2>/dev/null || echo "false")
SHOW_EXTENSIONS=$(defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null || echo "false")

echo "    \"finder\": {" >> "$OUTPUT_FILE"
echo "      \"show_hidden_files\": $SHOW_HIDDEN," >> "$OUTPUT_FILE"
echo "      \"show_all_extensions\": $SHOW_EXTENSIONS" >> "$OUTPUT_FILE"
echo "    }," >> "$OUTPUT_FILE"

# Keyboard settings
KEY_REPEAT=$(defaults read NSGlobalDomain KeyRepeat 2>/dev/null || echo "null")
INIT_REPEAT=$(defaults read NSGlobalDomain InitialKeyRepeat 2>/dev/null || echo "null")

echo "    \"keyboard\": {" >> "$OUTPUT_FILE"
echo "      \"key_repeat\": $KEY_REPEAT," >> "$OUTPUT_FILE"
echo "      \"initial_key_repeat\": $INIT_REPEAT" >> "$OUTPUT_FILE"
echo "    }," >> "$OUTPUT_FILE"

# Trackpad settings
TRACKPAD_SPEED=$(defaults read NSGlobalDomain com.apple.trackpad.scaling 2>/dev/null || echo "null")
TAP_TO_CLICK=$(defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking 2>/dev/null || echo "null")

echo "    \"trackpad\": {" >> "$OUTPUT_FILE"
echo "      \"tracking_speed\": $TRACKPAD_SPEED," >> "$OUTPUT_FILE"
echo "      \"tap_to_click\": $TAP_TO_CLICK" >> "$OUTPUT_FILE"
echo "    }," >> "$OUTPUT_FILE"

# Screenshot settings
SCREENSHOT_LOCATION=$(defaults read com.apple.screencapture location 2>/dev/null || echo "null")
SCREENSHOT_TYPE=$(defaults read com.apple.screencapture type 2>/dev/null || echo "null")

echo "    \"screenshots\": {" >> "$OUTPUT_FILE"
echo "      \"location\": \"$SCREENSHOT_LOCATION\"," >> "$OUTPUT_FILE"
echo "      \"type\": \"$SCREENSHOT_TYPE\"" >> "$OUTPUT_FILE"
echo "    }" >> "$OUTPUT_FILE"

echo "  }" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

# Pretty-print the JSON
if command -v python3 &> /dev/null; then
    python3 -m json.tool "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
fi

# Build summary file
{
    echo "========================================"
    echo "System Preferences Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo "OS Version: $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
    echo ""

    echo "========================================"
    echo "Key Settings Summary"
    echo "========================================"
    echo ""
    echo "Dock:"
    echo "  Autohide: $DOCK_AUTOHIDE"
    echo "  Orientation: $DOCK_ORIENTATION"
    echo "  Tile Size: $DOCK_TILESIZE"
    echo ""
    echo "Finder:"
    echo "  Show Hidden Files: $SHOW_HIDDEN"
    echo "  Show All Extensions: $SHOW_EXTENSIONS"
    echo ""
    echo "Keyboard:"
    echo "  Key Repeat: $KEY_REPEAT"
    echo "  Initial Key Repeat: $INIT_REPEAT"
    echo ""
    echo "Trackpad:"
    echo "  Tracking Speed: $TRACKPAD_SPEED"
    echo "  Tap to Click: $TAP_TO_CLICK"
    echo ""
    echo "Screenshots:"
    echo "  Location: $SCREENSHOT_LOCATION"
    echo "  Type: $SCREENSHOT_TYPE"
    echo ""

    echo "========================================"
    echo "Exported Preference Domains"
    echo "========================================"
    ls -1 "$PLIST_DIR" | sed 's/^/  /'
    echo ""
    echo "Total domains exported: $(ls -1 "$PLIST_DIR" | wc -l | tr -d ' ')"
} > "$SUMMARY_FILE"

echo ""
echo "System preferences captured successfully!"
echo "JSON output: $OUTPUT_FILE"
echo "Plist exports: $PLIST_DIR"
echo "Summary: $SUMMARY_FILE"
echo ""
echo "Preview:"
head -30 "$SUMMARY_FILE"
