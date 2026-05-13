#!/bin/bash
#
# capture-shell-config.sh
# Captures shell configuration files
#
# Output: Copies of dotfiles and shell profiles
# Usage: ./capture-shell-config.sh [output_dir]

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

OUTPUT_FILE="$OUTPUT_DIR/shell-config.json"
SUMMARY_FILE="$OUTPUT_DIR/shell-config.txt"
CONFIG_DIR="$OUTPUT_DIR/dotfiles"
mkdir -p "$CONFIG_DIR"

echo "Capturing shell configuration state..."
echo "Output directory: $OUTPUT_DIR"

# Shell config files to capture
SHELL_CONFIGS=(
    ".bashrc"
    ".bash_profile"
    ".bash_login"
    ".profile"
    ".zshrc"
    ".zshenv"
    ".zprofile"
    ".zlogin"
    ".zlogout"
    ".config/fish/config.fish"
    ".inputrc"
    ".editrc"
)

# Start building JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"capture_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$OUTPUT_FILE"
echo "  \"hostname\": \"$(hostname)\"," >> "$OUTPUT_FILE"
echo "  \"user\": \"$USER\"," >> "$OUTPUT_FILE"
echo "  \"current_shell\": \"$SHELL\"," >> "$OUTPUT_FILE"
echo "  \"captured_files\": [" >> "$OUTPUT_FILE"

CAPTURED_COUNT=0
first=true

for config_file in "${SHELL_CONFIGS[@]}"; do
    full_path="$HOME/$config_file"
    if [[ -f "$full_path" ]]; then
        # Create subdirectories if needed
        config_subdir=$(dirname "$config_file")
        if [[ "$config_subdir" != "." ]]; then
            mkdir -p "$CONFIG_DIR/$config_subdir"
        fi

        # Copy the file
        cp "$full_path" "$CONFIG_DIR/$config_file"

        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$OUTPUT_FILE"
        fi

        file_size=$(wc -c < "$full_path" | tr -d ' ')
        line_count=$(wc -l < "$full_path" | tr -d ' ')

        echo -n "    {\"file\": \"$config_file\", \"size\": $file_size, \"lines\": $line_count}" >> "$OUTPUT_FILE"
        ((CAPTURED_COUNT++))
    fi
done

echo "" >> "$OUTPUT_FILE"
echo "  ]" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

# Pretty-print the JSON
if command -v python3 &> /dev/null; then
    python3 -m json.tool "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
fi

# Build summary file
{
    echo "========================================"
    echo "Shell Configuration Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo "Current Shell: $SHELL"
    echo ""

    echo "========================================"
    echo "Captured Configuration Files"
    echo "========================================"
    if [[ $CAPTURED_COUNT -gt 0 ]]; then
        for config_file in "${SHELL_CONFIGS[@]}"; do
            full_path="$HOME/$config_file"
            if [[ -f "$full_path" ]]; then
                line_count=$(wc -l < "$full_path" | tr -d ' ')
                file_size=$(ls -lh "$full_path" | awk '{print $5}')
                printf "  %-30s %5s  %6s lines\n" "$config_file" "$file_size" "$line_count"
            fi
        done
        echo ""
        echo "Total files captured: $CAPTURED_COUNT"
    else
        echo "  (none found)"
    fi
    echo ""

    echo "========================================"
    echo "Shell Aliases (from current session)"
    echo "========================================"
    if command -v alias &> /dev/null; then
        alias 2>/dev/null | head -20 | sed 's/^/  /'
        echo ""
        echo "  (showing first 20 aliases)"
    else
        echo "  (unable to capture)"
    fi
    echo ""

    echo "========================================"
    echo "Custom Functions (sample)"
    echo "========================================"
    # Try to find function definitions in captured files
    if [[ $CAPTURED_COUNT -gt 0 ]]; then
        for config_file in "${SHELL_CONFIGS[@]}"; do
            full_path="$HOME/$config_file"
            if [[ -f "$full_path" ]]; then
                grep -E "^function |^[a-zA-Z_][a-zA-Z0-9_]*\(\)" "$full_path" 2>/dev/null | head -5 | sed 's/^/  /'
            fi
        done | head -10
        echo ""
        echo "  (showing sample of custom functions)"
    fi
} > "$SUMMARY_FILE"

echo ""
echo "Shell configuration captured successfully!"
echo "JSON output: $OUTPUT_FILE"
echo "Dotfiles: $CONFIG_DIR"
echo "Summary: $SUMMARY_FILE"
echo "Captured: $CAPTURED_COUNT configuration files"
echo ""
echo "Preview:"
head -30 "$SUMMARY_FILE"
