#!/bin/bash
#
# capture-steam-game-state.sh
# Captures installed Steam games
#
# Output: List of all Steam games installed
# Usage: ./capture-steam-game-state.sh [output_dir]

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

OUTPUT_FILE="$OUTPUT_DIR/steam-games.json"
SUMMARY_FILE="$OUTPUT_DIR/steam-games.txt"

echo "Capturing Steam game state..."
echo "Output directory: $OUTPUT_DIR"

# Common Steam library locations
STEAM_LIBRARIES=(
    "$HOME/Library/Application Support/Steam/steamapps"
    "/Applications/Steam.app/Contents/MacOS/steamapps"
    "$HOME/.local/share/Steam/steamapps"
)

# Start building JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"capture_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$OUTPUT_FILE"
echo "  \"hostname\": \"$(hostname)\"," >> "$OUTPUT_FILE"
echo "  \"user\": \"$USER\"," >> "$OUTPUT_FILE"
echo "  \"steam_libraries\": [" >> "$OUTPUT_FILE"

TOTAL_GAMES=0
first_library=true

for steam_dir in "${STEAM_LIBRARIES[@]}"; do
    [[ ! -d "$steam_dir" ]] && continue

    if [[ "$first_library" == "true" ]]; then
        first_library=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi

    echo "    {" >> "$OUTPUT_FILE"
    echo "      \"path\": \"$steam_dir\"," >> "$OUTPUT_FILE"
    echo "      \"games\": [" >> "$OUTPUT_FILE"

    library_game_count=0
    first_game=true

    # Find all .acf manifest files (these track installed games)
    if [[ -f "$steam_dir/libraryfolders.vdf" ]] || [[ -d "$steam_dir" ]]; then
        while IFS= read -r acf_file; do
            [[ -z "$acf_file" ]] && continue

            # Extract app ID and name from .acf file
            app_id=$(grep -E "^\s*\"appid\"" "$acf_file" 2>/dev/null | head -1 | sed 's/.*"\([0-9]*\)".*/\1/' || echo "unknown")
            game_name=$(grep -E "^\s*\"name\"" "$acf_file" 2>/dev/null | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "unknown")
            install_dir=$(grep -E "^\s*\"installdir\"" "$acf_file" 2>/dev/null | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "unknown")

            # Get size if possible
            if [[ -n "$install_dir" && "$install_dir" != "unknown" ]]; then
                game_path="$steam_dir/common/$install_dir"
                if [[ -d "$game_path" ]]; then
                    size=$(du -sh "$game_path" 2>/dev/null | awk '{print $1}' || echo "unknown")
                else
                    size="unknown"
                fi
            else
                size="unknown"
            fi

            if [[ "$first_game" == "true" ]]; then
                first_game=false
            else
                echo "," >> "$OUTPUT_FILE"
            fi

            # Escape quotes in game name
            escaped_name=$(echo "$game_name" | sed 's/"/\\"/g')

            echo -n "        {\"app_id\": \"$app_id\", \"name\": \"$escaped_name\", \"install_dir\": \"$install_dir\", \"size\": \"$size\"}" >> "$OUTPUT_FILE"
            ((library_game_count++))
            ((TOTAL_GAMES++))
        done < <(find "$steam_dir" -maxdepth 1 -name "appmanifest_*.acf" -type f 2>/dev/null | sort)
    fi

    echo "" >> "$OUTPUT_FILE"
    echo "      ]," >> "$OUTPUT_FILE"
    echo "      \"game_count\": $library_game_count" >> "$OUTPUT_FILE"
    echo -n "    }" >> "$OUTPUT_FILE"
done

echo "" >> "$OUTPUT_FILE"
echo "  ]," >> "$OUTPUT_FILE"
echo "  \"total_games\": $TOTAL_GAMES" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

# Pretty-print the JSON
if command -v python3 &> /dev/null; then
    python3 -m json.tool "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
fi

# Build summary file
{
    echo "========================================"
    echo "Steam Games Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo ""

    if [[ $TOTAL_GAMES -eq 0 ]]; then
        echo "No Steam games found"
        echo ""
        echo "Searched locations:"
        for steam_dir in "${STEAM_LIBRARIES[@]}"; do
            if [[ -d "$steam_dir" ]]; then
                echo "  $steam_dir (exists but no games)"
            else
                echo "  $steam_dir (not found)"
            fi
        done
    else
        for steam_dir in "${STEAM_LIBRARIES[@]}"; do
            [[ ! -d "$steam_dir" ]] && continue

            echo "========================================"
            echo "Steam Library: $steam_dir"
            echo "========================================"
            echo ""

            # List games
            game_num=1
            while IFS= read -r acf_file; do
                [[ -z "$acf_file" ]] && continue

                app_id=$(grep -E "^\s*\"appid\"" "$acf_file" 2>/dev/null | head -1 | sed 's/.*"\([0-9]*\)".*/\1/' || echo "?")
                game_name=$(grep -E "^\s*\"name\"" "$acf_file" 2>/dev/null | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "unknown")
                install_dir=$(grep -E "^\s*\"installdir\"" "$acf_file" 2>/dev/null | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "unknown")

                # Get size
                if [[ -n "$install_dir" && "$install_dir" != "unknown" ]]; then
                    game_path="$steam_dir/common/$install_dir"
                    if [[ -d "$game_path" ]]; then
                        size=$(du -sh "$game_path" 2>/dev/null | awk '{print $1}' || echo "?")
                    else
                        size="?"
                    fi
                else
                    size="?"
                fi

                printf "%3d. %-50s %10s  App ID: %s\n" "$game_num" "$game_name" "$size" "$app_id"
                ((game_num++))
            done < <(find "$steam_dir" -maxdepth 1 -name "appmanifest_*.acf" -type f 2>/dev/null | sort)
            echo ""
        done

        echo "========================================"
        echo "Summary"
        echo "========================================"
        echo "Total games installed: $TOTAL_GAMES"
    fi
} > "$SUMMARY_FILE"

echo ""
echo "Steam game state captured successfully!"
echo "JSON output: $OUTPUT_FILE"
echo "Summary: $SUMMARY_FILE"
echo "Total games: $TOTAL_GAMES"
echo ""
echo "Preview:"
head -40 "$SUMMARY_FILE"
