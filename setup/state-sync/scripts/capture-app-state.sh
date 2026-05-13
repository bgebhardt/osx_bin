#!/bin/bash
#
# capture-app-state.sh
# Captures all installed applications (Homebrew, Mac App Store, manual installs)
#
# Output: JSON file with app names, versions, install methods
# Usage: ./capture-app-state.sh [output_dir]

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

OUTPUT_FILE="$OUTPUT_DIR/app-state.json"
SUMMARY_FILE="$OUTPUT_DIR/app-state.txt"

echo "Capturing application state..."
echo "Output directory: $OUTPUT_DIR"

# Start building JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"capture_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$OUTPUT_FILE"
echo "  \"hostname\": \"$(hostname)\"," >> "$OUTPUT_FILE"
echo "  \"user\": \"$USER\"," >> "$OUTPUT_FILE"

# Homebrew formulae
echo "  \"homebrew\": {" >> "$OUTPUT_FILE"
echo "    \"formulae\": [" >> "$OUTPUT_FILE"
if command -v brew &> /dev/null; then
    FORMULAE=$(brew list --formula 2>/dev/null || echo "")
    if [[ -n "$FORMULAE" ]]; then
        first=true
        while IFS= read -r formula; do
            [[ -z "$formula" ]] && continue
            version=$(brew list --versions "$formula" 2>/dev/null | awk '{print $2}' || echo "unknown")
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo "," >> "$OUTPUT_FILE"
            fi
            echo -n "      {\"name\": \"$formula\", \"version\": \"$version\"}" >> "$OUTPUT_FILE"
        done <<< "$FORMULAE"
        echo "" >> "$OUTPUT_FILE"
    fi
fi
echo "    ]," >> "$OUTPUT_FILE"

# Homebrew casks
echo "    \"casks\": [" >> "$OUTPUT_FILE"
if command -v brew &> /dev/null; then
    CASKS=$(brew list --cask 2>/dev/null || echo "")
    if [[ -n "$CASKS" ]]; then
        first=true
        while IFS= read -r cask; do
            [[ -z "$cask" ]] && continue
            version=$(brew list --cask --versions "$cask" 2>/dev/null | awk '{print $2}' || echo "unknown")
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo "," >> "$OUTPUT_FILE"
            fi
            echo -n "      {\"name\": \"$cask\", \"version\": \"$version\"}" >> "$OUTPUT_FILE"
        done <<< "$CASKS"
        echo "" >> "$OUTPUT_FILE"
    fi
fi
echo "    ]" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# Mac App Store apps
echo "  \"mac_app_store\": [" >> "$OUTPUT_FILE"
if command -v mas &> /dev/null; then
    MAS_APPS=$(mas list 2>/dev/null || echo "")
    if [[ -n "$MAS_APPS" ]]; then
        first=true
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            app_id=$(echo "$line" | awk '{print $1}')
            app_name=$(echo "$line" | cut -d' ' -f2- | sed 's/ ([^)]*)$//')
            version=$(echo "$line" | grep -o '([^)]*)' | tr -d '()' || echo "unknown")
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo "," >> "$OUTPUT_FILE"
            fi
            echo -n "    {\"id\": \"$app_id\", \"name\": \"$app_name\", \"version\": \"$version\"}" >> "$OUTPUT_FILE"
        done <<< "$MAS_APPS"
        echo "" >> "$OUTPUT_FILE"
    fi
fi
echo "  ]," >> "$OUTPUT_FILE"

# Applications directory apps (manual installs)
echo "  \"applications\": [" >> "$OUTPUT_FILE"
if [[ -d "/Applications" ]]; then
    first=true
    while IFS= read -r app; do
        [[ -z "$app" ]] && continue
        app_name=$(basename "$app" .app)
        # Try to get version from Info.plist
        plist="$app/Contents/Info.plist"
        if [[ -f "$plist" ]]; then
            version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist" 2>/dev/null || echo "unknown")
        else
            version="unknown"
        fi
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$OUTPUT_FILE"
        fi
        # Escape quotes in app name
        escaped_name=$(echo "$app_name" | sed 's/"/\\"/g')
        echo -n "    {\"name\": \"$escaped_name\", \"version\": \"$version\"}" >> "$OUTPUT_FILE"
    done < <(find /Applications -maxdepth 1 -name "*.app" -type d 2>/dev/null | sort)
    echo "" >> "$OUTPUT_FILE"
fi
echo "  ]" >> "$OUTPUT_FILE"

echo "}" >> "$OUTPUT_FILE"

# Pretty-print the JSON
if command -v python3 &> /dev/null; then
    python3 -m json.tool "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
fi

# Build summary file
{
    echo "========================================"
    echo "Application State Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo ""

    if command -v brew &> /dev/null; then
        FORMULA_COUNT=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
        CASK_COUNT=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
        echo "Homebrew Formulae: $FORMULA_COUNT"
        echo "Homebrew Casks: $CASK_COUNT"
    else
        echo "Homebrew: Not installed"
    fi

    if command -v mas &> /dev/null; then
        MAS_COUNT=$(mas list 2>/dev/null | wc -l | tr -d ' ')
        echo "Mac App Store Apps: $MAS_COUNT"
    else
        echo "Mac App Store CLI: Not installed"
    fi

    APP_COUNT=$(find /Applications -maxdepth 1 -name "*.app" -type d 2>/dev/null | wc -l | tr -d ' ')
    echo "Applications Directory: $APP_COUNT apps"
    echo ""

    echo "========================================"
    echo "Top 20 Applications"
    echo "========================================"
    find /Applications -maxdepth 1 -name "*.app" -type d 2>/dev/null | \
        xargs -I {} basename {} .app | \
        sort | \
        head -20
} > "$SUMMARY_FILE"

echo ""
echo "Application state captured successfully!"
echo "JSON output: $OUTPUT_FILE"
echo "Summary: $SUMMARY_FILE"
echo ""
echo "Preview:"
head -30 "$SUMMARY_FILE"
