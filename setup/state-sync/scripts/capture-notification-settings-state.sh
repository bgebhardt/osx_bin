#!/bin/bash
#
# capture-notification-settings-state.sh
# Captures notification settings for all apps
# Focuses on non-default settings to help with porting to new machines
#
# Output: JSON file with notification settings per app
# Usage: ./capture-notification-settings-state.sh [output_dir]

set -euo pipefail

# Default output directory
OUTPUT_DIR="${1:-$HOME/bin/setup/state-sync/snapshots/$(date +%Y-%m-%d-%H%M%S)}"
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/notification-settings.json"
SUMMARY_FILE="$OUTPUT_DIR/notification-settings.txt"

echo "Capturing notification settings state..."
echo "Output directory: $OUTPUT_DIR"

# Notification settings are stored in a database
# We'll use notificationutil (private tool) if available, otherwise read the plist/db directly
NOTIF_DB="$HOME/Library/Application Support/NotificationCenter"
NOTIF_PLIST="$HOME/Library/Preferences/com.apple.ncprefs.plist"

# Function to get notification settings using defaults
get_notification_settings() {
    if [[ -f "$NOTIF_PLIST" ]]; then
        defaults read com.apple.ncprefs 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Function to parse notification center database
get_notif_center_apps() {
    # Try to read the plist for app list
    if [[ -f "$NOTIF_PLIST" ]]; then
        # Get the apps section
        defaults read com.apple.ncprefs apps 2>/dev/null | \
            grep -E "(bundle-id|flags)" | \
            sed 's/^[[:space:]]*//' || echo ""
    fi
}

# Function to check if notifications are allowed for an app
check_app_notifications() {
    local bundle_id="$1"
    defaults read com.apple.ncprefs.plist 2>/dev/null | \
        grep -A 20 "$bundle_id" | \
        grep -E "(flags|badge|sound|alert)" | \
        head -10 || echo ""
}

# Start building JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"capture_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$OUTPUT_FILE"
echo "  \"hostname\": \"$(hostname)\"," >> "$OUTPUT_FILE"
echo "  \"user\": \"$USER\"," >> "$OUTPUT_FILE"
echo "  \"notification_settings\": {" >> "$OUTPUT_FILE"

# Start building summary
{
    echo "========================================"
    echo "Notification Settings State Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo ""
    echo "Note: This captures apps with non-default notification settings"
    echo ""
} > "$SUMMARY_FILE"

# Get all notification settings
NOTIF_DATA=$(get_notification_settings)

# Extract app information
if [[ -n "$NOTIF_DATA" ]]; then
    # Parse the plist output to extract app bundle IDs and their settings
    echo "    \"apps\": [" >> "$OUTPUT_FILE"

    # Use PlistBuddy for more reliable parsing
    if command -v /usr/libexec/PlistBuddy &> /dev/null; then
        # Get the number of apps
        NUM_APPS=$(/usr/libexec/PlistBuddy -c "Print :apps" "$NOTIF_PLIST" 2>/dev/null | grep -c "Dict" || echo "0")

        if [[ "$NUM_APPS" -gt 0 ]]; then
            for ((i=0; i<NUM_APPS; i++)); do
                BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:bundle-id" "$NOTIF_PLIST" 2>/dev/null || echo "")
                FLAGS=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:flags" "$NOTIF_PLIST" 2>/dev/null || echo "0")

                if [[ -n "$BUNDLE_ID" ]]; then
                    # Add comma for all but first entry
                    if [[ $i -gt 0 ]]; then
                        echo "," >> "$OUTPUT_FILE"
                    fi

                    # Determine settings based on flags (bitwise)
                    # Common flag values:
                    # 0 = notifications off
                    # 178 = banners, sounds, badges (typical default)
                    # flags is a bitfield that controls various notification settings

                    ALERTS_ENABLED="unknown"
                    BADGES_ENABLED="unknown"
                    SOUNDS_ENABLED="unknown"

                    # Try to get more specific settings
                    SHOW_IN_NC=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:show-in-notification-center" "$NOTIF_PLIST" 2>/dev/null || echo "unknown")
                    BADGE_APP=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:badge-app-icon" "$NOTIF_PLIST" 2>/dev/null || echo "unknown")
                    SHOW_PREVIEW=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:show-message-preview" "$NOTIF_PLIST" 2>/dev/null || echo "unknown")

                    echo "      {" >> "$OUTPUT_FILE"
                    echo "        \"bundle_id\": \"$BUNDLE_ID\"," >> "$OUTPUT_FILE"
                    echo "        \"flags\": $FLAGS," >> "$OUTPUT_FILE"
                    echo "        \"show_in_notification_center\": \"$SHOW_IN_NC\"," >> "$OUTPUT_FILE"
                    echo "        \"badge_app_icon\": \"$BADGE_APP\"," >> "$OUTPUT_FILE"
                    echo "        \"show_message_preview\": \"$SHOW_PREVIEW\"" >> "$OUTPUT_FILE"
                    echo -n "      }" >> "$OUTPUT_FILE"
                fi
            done
            echo "" >> "$OUTPUT_FILE"
        fi
    fi

    echo "    ]" >> "$OUTPUT_FILE"
else
    echo "    \"apps\": []" >> "$OUTPUT_FILE"
fi

echo "  }," >> "$OUTPUT_FILE"

# Add system-wide notification settings
echo "  \"system_settings\": {" >> "$OUTPUT_FILE"
DO_NOT_DISTURB=$(defaults read com.apple.ncprefs.plist dnd_prefs 2>/dev/null | grep -v "^{" | grep -v "^}" | sed 's/^[[:space:]]*//' || echo "")
echo "    \"do_not_disturb\": \"$DO_NOT_DISTURB\"" >> "$OUTPUT_FILE"
echo "  }" >> "$OUTPUT_FILE"

echo "}" >> "$OUTPUT_FILE"

# Build summary file
# Initialize NUM_APPS outside the heredoc
NUM_APPS=0
if command -v /usr/libexec/PlistBuddy &> /dev/null && [[ -f "$NOTIF_PLIST" ]]; then
    NUM_APPS=$(/usr/libexec/PlistBuddy -c "Print :apps" "$NOTIF_PLIST" 2>/dev/null | grep -c "Dict" || echo "0")
fi

{
    echo "========================================"
    echo "Apps with Notification Settings"
    echo "========================================"

    if command -v /usr/libexec/PlistBuddy &> /dev/null && [[ -f "$NOTIF_PLIST" ]]; then
        echo "Total apps with notification settings: $NUM_APPS"
        echo ""

        if [[ "$NUM_APPS" -gt 0 ]]; then
            echo "Bundle ID                                    | Flags | Badges | NC"
            echo "-------------------------------------------- | ----- | ------ | ---"

            for ((i=0; i<NUM_APPS; i++)); do
                BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:bundle-id" "$NOTIF_PLIST" 2>/dev/null || echo "")
                FLAGS=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:flags" "$NOTIF_PLIST" 2>/dev/null || echo "0")
                BADGE=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:badge-app-icon" "$NOTIF_PLIST" 2>/dev/null || echo "?")
                SHOW_NC=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:show-in-notification-center" "$NOTIF_PLIST" 2>/dev/null || echo "?")

                if [[ -n "$BUNDLE_ID" ]]; then
                    # Truncate long bundle IDs
                    BUNDLE_SHORT=$(echo "$BUNDLE_ID" | cut -c 1-44)
                    printf "%-44s | %5s | %6s | %s\n" "$BUNDLE_SHORT" "$FLAGS" "$BADGE" "$SHOW_NC"
                fi
            done
        fi
    else
        echo "Could not read notification preferences."
        echo "Plist file: $NOTIF_PLIST"
    fi

    echo ""
    echo "========================================"
    echo "Non-Default Settings (Flags != 178)"
    echo "========================================"

    if [[ "$NUM_APPS" -gt 0 ]]; then
        for ((i=0; i<NUM_APPS; i++)); do
            BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:bundle-id" "$NOTIF_PLIST" 2>/dev/null || echo "")
            FLAGS=$(/usr/libexec/PlistBuddy -c "Print :apps:$i:flags" "$NOTIF_PLIST" 2>/dev/null || echo "0")

            if [[ -n "$BUNDLE_ID" && "$FLAGS" != "178" ]]; then
                echo "$BUNDLE_ID (flags=$FLAGS)"
            fi
        done
    fi

} >> "$SUMMARY_FILE"

# Pretty-print the JSON file
if command -v python3 &> /dev/null; then
    python3 -m json.tool "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
fi

echo ""
echo "Notification settings captured successfully!"
echo "JSON output: $OUTPUT_FILE"
echo "Summary: $SUMMARY_FILE"
echo ""
echo "Preview:"
head -30 "$SUMMARY_FILE"
