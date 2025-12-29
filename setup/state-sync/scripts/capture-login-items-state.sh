#!/bin/bash
#
# capture-login-items-state.sh
# Captures all login items for each user on the system
#
# Output: JSON file with login items organized by user
# Usage: ./capture-login-items-state.sh [output_dir]

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

OUTPUT_FILE="$OUTPUT_DIR/login-items.json"
SUMMARY_FILE="$OUTPUT_DIR/login-items.txt"

echo "Capturing login items state..."
echo "Output directory: $OUTPUT_DIR"

# Function to get login items for current user using osascript
get_login_items_osascript() {
    osascript -e 'tell application "System Events"
        get the name of every login item
    end tell' 2>/dev/null || echo ""
}

# Function to get login items using sfltool (more comprehensive)
get_login_items_sfltool() {
    sfltool dumpbtm 2>/dev/null | grep -E "^[[:space:]]+(Name|Path|URL)" | sed 's/^[[:space:]]*//' || echo ""
}

# Function to get login items from LaunchAgents
get_launch_agents() {
    local user_dir="$1"
    if [[ -d "$user_dir/Library/LaunchAgents" ]]; then
        find "$user_dir/Library/LaunchAgents" -name "*.plist" -type f -exec basename {} \; 2>/dev/null | sort
    fi
}

# Function to get background items (macOS 13+)
get_background_items() {
    # Use sfltool to get Service Management login items
    sfltool dumpbtm 2>/dev/null | awk '
        /^Bundle Identifier:/ { bundle = $3 }
        /^Name:/ { name = $2 }
        /^Developer Name:/ { dev = $3; if (name && bundle) print name " (" bundle ")" }
    ' | sort -u || echo ""
}

# Start building JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"capture_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$OUTPUT_FILE"
echo "  \"hostname\": \"$(hostname)\"," >> "$OUTPUT_FILE"
echo "  \"current_user\": \"$USER\"," >> "$OUTPUT_FILE"
echo "  \"login_items\": {" >> "$OUTPUT_FILE"

# Start building summary
{
    echo "========================================"
    echo "Login Items State Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "Current User: $USER"
    echo ""
} > "$SUMMARY_FILE"

# Get login items for current user
echo "    \"$USER\": {" >> "$OUTPUT_FILE"

# Classic login items (System Preferences > Users & Groups > Login Items)
echo "      \"classic_login_items\": [" >> "$OUTPUT_FILE"
CLASSIC_ITEMS=$(get_login_items_osascript)
if [[ -n "$CLASSIC_ITEMS" ]]; then
    first=true
    # Split on comma since osascript returns comma-separated list
    IFS=',' read -ra ITEMS <<< "$CLASSIC_ITEMS"
    for item in "${ITEMS[@]}"; do
        # Trim leading/trailing whitespace
        item=$(echo "$item" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -z "$item" ]] && continue
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$OUTPUT_FILE"
        fi
        echo -n "        \"$item\"" >> "$OUTPUT_FILE"
    done
    echo "" >> "$OUTPUT_FILE"
fi
echo "      ]," >> "$OUTPUT_FILE"

# Background items (modern Service Management framework)
echo "      \"background_items\": [" >> "$OUTPUT_FILE"
BG_ITEMS=$(get_background_items)
if [[ -n "$BG_ITEMS" ]]; then
    first=true
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$OUTPUT_FILE"
        fi
        # Escape quotes in item name
        escaped_item=$(echo "$item" | sed 's/"/\\"/g')
        echo -n "        \"$escaped_item\"" >> "$OUTPUT_FILE"
    done <<< "$BG_ITEMS"
    echo "" >> "$OUTPUT_FILE"
fi
echo "      ]," >> "$OUTPUT_FILE"

# LaunchAgents
echo "      \"launch_agents\": [" >> "$OUTPUT_FILE"
LAUNCH_AGENTS=$(get_launch_agents "$HOME")
if [[ -n "$LAUNCH_AGENTS" ]]; then
    first=true
    while IFS= read -r agent; do
        [[ -z "$agent" ]] && continue
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$OUTPUT_FILE"
        fi
        echo -n "        \"$agent\"" >> "$OUTPUT_FILE"
    done <<< "$LAUNCH_AGENTS"
    echo "" >> "$OUTPUT_FILE"
fi
echo "      ]" >> "$OUTPUT_FILE"

echo "    }" >> "$OUTPUT_FILE"
echo "  }" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

# Build summary file
{
    echo "========================================"
    echo "Classic Login Items (System Preferences)"
    echo "========================================"
    if [[ -n "$CLASSIC_ITEMS" ]]; then
        echo "$CLASSIC_ITEMS"
    else
        echo "(none found)"
    fi
    echo ""

    echo "========================================"
    echo "Background Items (Service Management)"
    echo "========================================"
    if [[ -n "$BG_ITEMS" ]]; then
        echo "$BG_ITEMS"
    else
        echo "(none found)"
    fi
    echo ""

    echo "========================================"
    echo "Launch Agents"
    echo "========================================"
    if [[ -n "$LAUNCH_AGENTS" ]]; then
        echo "$LAUNCH_AGENTS"
    else
        echo "(none found)"
    fi
    echo ""

    echo "Total Classic Login Items: $(echo "$CLASSIC_ITEMS" | grep -c . || echo 0)"
    echo "Total Background Items: $(echo "$BG_ITEMS" | grep -c . || echo 0)"
    echo "Total Launch Agents: $(echo "$LAUNCH_AGENTS" | grep -c . || echo 0)"
} >> "$SUMMARY_FILE"

# Pretty-print the JSON file
if command -v python3 &> /dev/null; then
    python3 -m json.tool "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
fi

echo ""
echo "Login items captured successfully!"
echo "JSON output: $OUTPUT_FILE"
echo "Summary: $SUMMARY_FILE"
echo ""
echo "Preview:"
head -20 "$SUMMARY_FILE"
