#!/bin/bash
#
# capture-app-prefs.sh
# Captures application preferences for commonly configured apps
#
# Output: Plist exports for configured applications
# Usage: ./capture-app-prefs.sh [output_dir]

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

OUTPUT_FILE="$OUTPUT_DIR/app-prefs.json"
SUMMARY_FILE="$OUTPUT_DIR/app-prefs.txt"
PLIST_DIR="$OUTPUT_DIR/app-plists"
mkdir -p "$PLIST_DIR"

echo "Capturing application preferences state..."
echo "Output directory: $OUTPUT_DIR"

# Common application preference domains
APP_DOMAINS=(
    "com.apple.Terminal"
    "com.googlecode.iterm2"
    "com.microsoft.VSCode"
    "com.google.Chrome"
    "com.apple.Safari"
    "com.mozilla.firefox"
    "com.sublimetext.3"
    "com.sublimetext.4"
    "com.jetbrains.intellij"
    "com.microsoft.Word"
    "com.microsoft.Excel"
    "com.microsoft.Powerpoint"
    "com.spotify.client"
    "com.adobe.Reader"
    "com.parallels.desktop.console"
    "com.vmware.fusion"
    "org.videolan.vlc"
)

# Start building JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"capture_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$OUTPUT_FILE"
echo "  \"hostname\": \"$(hostname)\"," >> "$OUTPUT_FILE"
echo "  \"user\": \"$USER\"," >> "$OUTPUT_FILE"
echo "  \"app_preferences\": {" >> "$OUTPUT_FILE"

EXPORTED_COUNT=0
first_domain=true

for domain in "${APP_DOMAINS[@]}"; do
    # Check if preferences exist for this domain
    if defaults read "$domain" &>/dev/null; then
        # Export plist to file
        if defaults export "$domain" "$PLIST_DIR/$domain.plist" 2>/dev/null; then
            if [[ "$first_domain" == "true" ]]; then
                first_domain=false
            else
                echo "," >> "$OUTPUT_FILE"
            fi
            echo -n "    \"$domain\": \"exported\"" >> "$OUTPUT_FILE"
            ((EXPORTED_COUNT++))
        fi
    fi
done

echo "" >> "$OUTPUT_FILE"
echo "  }" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

# Pretty-print the JSON
if command -v python3 &> /dev/null; then
    python3 -m json.tool "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
fi

# Build summary file
{
    echo "========================================"
    echo "Application Preferences Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo ""

    echo "========================================"
    echo "Exported Application Preferences"
    echo "========================================"
    if [[ $EXPORTED_COUNT -gt 0 ]]; then
        ls -1 "$PLIST_DIR" 2>/dev/null | sed 's/\.plist$//' | sed 's/^/  /'
        echo ""
        echo "Total apps with preferences exported: $EXPORTED_COUNT"
    else
        echo "  (none found)"
    fi
    echo ""

    echo "========================================"
    echo "File Sizes"
    echo "========================================"
    if [[ $EXPORTED_COUNT -gt 0 ]]; then
        ls -lh "$PLIST_DIR" | tail -n +2 | awk '{print "  " $9 ": " $5}'
    fi
} > "$SUMMARY_FILE"

echo ""
echo "Application preferences captured successfully!"
echo "JSON output: $OUTPUT_FILE"
echo "Plist exports: $PLIST_DIR"
echo "Summary: $SUMMARY_FILE"
echo "Exported: $EXPORTED_COUNT app preference files"
echo ""
echo "Preview:"
cat "$SUMMARY_FILE"
