#!/bin/bash
#
# capture-onedrive-state.sh
# Captures OneDrive local storage state (which folders are pinned locally)
# Finds all folders using more than 50KB of local storage
#
# Output: JSON and text report of locally stored OneDrive folders
# Usage: ./capture-onedrive-state.sh [output_dir]

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

OUTPUT_FILE="$OUTPUT_DIR/onedrive-state.json"
SUMMARY_FILE="$OUTPUT_DIR/onedrive-state.txt"

echo "Capturing OneDrive state..."
echo "Output directory: $OUTPUT_DIR"

# Configuration
THRESHOLD_KB=50
MAX_DEPTH=4

# Find OneDrive directories (skip symlinks that point to paths we'll already process)
ONEDRIVE_PATHS=()
SEEN_PATHS=()

# Helper to get canonical path
get_canonical_path() {
    if [[ -L "$1" ]]; then
        readlink "$1"
    else
        echo "$1"
    fi
}

# Add OneDrive paths, avoiding duplicates from symlinks
add_onedrive_path() {
    local path="$1"
    [[ ! -d "$path" ]] && return

    local canonical_path=$(get_canonical_path "$path")

    # Check if we've already seen this canonical path
    if [[ ${#SEEN_PATHS[@]} -gt 0 ]]; then
        for seen in "${SEEN_PATHS[@]}"; do
            if [[ "$seen" == "$canonical_path" ]]; then
                return
            fi
        done
    fi

    ONEDRIVE_PATHS+=("$path")
    SEEN_PATHS+=("$canonical_path")
}

add_onedrive_path "$HOME/Library/CloudStorage/OneDrive-Personal"
add_onedrive_path "$HOME/Library/CloudStorage/OneDrive-Microsoft"
add_onedrive_path "$HOME/OneDrive"

if [[ ${#ONEDRIVE_PATHS[@]} -eq 0 ]]; then
    echo "No OneDrive directories found"
    # Create empty output files
    echo "{\"capture_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"onedrive_instances\": []}" > "$OUTPUT_FILE"
    echo "No OneDrive directories found" > "$SUMMARY_FILE"
    echo "OneDrive state captured successfully!"
    exit 0
fi

# Recursive scanning function
scan_directory() {
    local dir="$1"
    local current_depth="$2"
    local temp_all="$3"
    local temp_queue="$4"

    # Get size of this directory
    local size
    size=$(du -sk "$dir" 2>/dev/null | cut -f1 || echo "0")

    # Skip if below threshold (cloud-only)
    if [[ -z "$size" ]] || [[ "$size" -le "$THRESHOLD_KB" ]]; then
        return
    fi

    # If we're at max depth, record this folder and stop
    if [[ "$current_depth" -ge "$MAX_DEPTH" ]]; then
        echo "$size|$current_depth|$dir" >> "$temp_all"
        return
    fi

    # This folder has local storage (> threshold)
    # Check subdirectories to see if we should drill deeper
    local subdirs_with_storage=$(mktemp)
    local subdirs_below_threshold=$(mktemp)
    local subdirs_list=$(mktemp)

    find -L "$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null > "$subdirs_list" || true

    # Check each subdir
    while IFS= read -r subdir; do
        [[ -z "$subdir" ]] && continue
        local subdir_size
        subdir_size=$(du -sk "$subdir" 2>/dev/null | cut -f1 || echo "0")

        if [[ -n "$subdir_size" ]]; then
            if [[ "$subdir_size" -gt "$THRESHOLD_KB" ]]; then
                # Subdir has local storage
                echo "$subdir" >> "$subdirs_with_storage"
            else
                # Subdir is cloud-only (below threshold)
                echo "$subdir" >> "$subdirs_below_threshold"
            fi
        fi
    done < "$subdirs_list"

    # Count results
    local num_with_storage=0
    local num_below_threshold=0
    [[ -s "$subdirs_with_storage" ]] && num_with_storage=$(wc -l < "$subdirs_with_storage" | tr -d ' ')
    [[ -s "$subdirs_below_threshold" ]] && num_below_threshold=$(wc -l < "$subdirs_below_threshold" | tr -d ' ')

    local total_subdirs=$((num_with_storage + num_below_threshold))

    # Decision logic:
    # - If no subdirs have storage: this is a leaf folder, record it
    # - If 90%+ of subdirs have storage: mostly populated, record it and stop
    # - If fewer than 90% have storage: mixed content, drill deeper
    if [[ "$num_with_storage" -eq 0 ]]; then
        # No subdirs with local storage - this is a leaf folder
        echo "$size|$current_depth|$dir" >> "$temp_all"
    elif [[ "$total_subdirs" -gt 0 ]]; then
        # Calculate percentage: (num_with_storage * 100) / total_subdirs
        local percentage=$((num_with_storage * 100 / total_subdirs))

        if [[ "$percentage" -ge 90 ]]; then
            # 90%+ of subdirs have local storage - consider this fully populated
            echo "$size|$current_depth|$dir" >> "$temp_all"
        else
            # Less than 90% - mixed content, drill deeper into subdirs with storage
            while IFS= read -r subdir; do
                [[ -z "$subdir" ]] && continue
                echo "$subdir|$((current_depth + 1))" >> "$temp_queue"
            done < "$subdirs_with_storage"
        fi
    fi

    rm -f "$subdirs_with_storage" "$subdirs_below_threshold" "$subdirs_list"
}

# Build JSON output
echo "{" > "$OUTPUT_FILE"
echo "  \"capture_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$OUTPUT_FILE"
echo "  \"hostname\": \"$(hostname)\"," >> "$OUTPUT_FILE"
echo "  \"user\": \"$USER\"," >> "$OUTPUT_FILE"
echo "  \"threshold_kb\": $THRESHOLD_KB," >> "$OUTPUT_FILE"
echo "  \"max_depth\": $MAX_DEPTH," >> "$OUTPUT_FILE"
echo "  \"onedrive_instances\": [" >> "$OUTPUT_FILE"

# Build summary output
{
    echo "========================================"
    echo "OneDrive State Snapshot"
    echo "========================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $USER"
    echo "Threshold: ${THRESHOLD_KB}KB"
    echo "Max Depth: $MAX_DEPTH"
    echo ""
} > "$SUMMARY_FILE"

first_instance=true
GRAND_TOTAL_FOLDERS=0
GRAND_TOTAL_SIZE_KB=0

for ONEDRIVE_PATH in "${ONEDRIVE_PATHS[@]}"; do
    [[ ! -d "$ONEDRIVE_PATH" ]] && continue

    instance_name=$(basename "$ONEDRIVE_PATH")

    echo "Scanning $instance_name (this may take a minute)..."

    # Create temporary files
    TEMP_ALL=$(mktemp)
    TEMP_QUEUE=$(mktemp)

    # Start with level 1 directories
    find -L "$ONEDRIVE_PATH" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r dir; do
        echo "$dir|1" >> "$TEMP_QUEUE"
    done || true

    # Process queue
    while [[ -s "$TEMP_QUEUE" ]]; do
        # Read one entry from queue
        if read -r line; then
            IFS='|' read -r dir depth <<< "$line"
            scan_directory "$dir" "$depth" "$TEMP_ALL" "$TEMP_QUEUE"
        fi < "$TEMP_QUEUE"

        # Remove processed line from queue
        tail -n +2 "$TEMP_QUEUE" > "${TEMP_QUEUE}.tmp" && mv "${TEMP_QUEUE}.tmp" "$TEMP_QUEUE"
    done

    # Sort results
    TEMP_FILTERED=$(mktemp)
    sort -t'|' -k2,2n -k1,1rn "$TEMP_ALL" > "$TEMP_FILTERED" 2>/dev/null || cat "$TEMP_ALL" > "$TEMP_FILTERED"

    # Count and calculate totals
    TOTAL_FOLDERS=$(wc -l < "$TEMP_FILTERED" | tr -d ' ')
    TOTAL_SIZE_KB=0
    while IFS='|' read -r size depth path; do
        TOTAL_SIZE_KB=$((TOTAL_SIZE_KB + size))
    done < "$TEMP_FILTERED"

    GRAND_TOTAL_FOLDERS=$((GRAND_TOTAL_FOLDERS + TOTAL_FOLDERS))
    GRAND_TOTAL_SIZE_KB=$((GRAND_TOTAL_SIZE_KB + TOTAL_SIZE_KB))

    # Add to JSON
    if [[ "$first_instance" == "true" ]]; then
        first_instance=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi

    echo "    {" >> "$OUTPUT_FILE"
    echo "      \"name\": \"$instance_name\"," >> "$OUTPUT_FILE"
    echo "      \"path\": \"$ONEDRIVE_PATH\"," >> "$OUTPUT_FILE"
    echo "      \"total_folders\": $TOTAL_FOLDERS," >> "$OUTPUT_FILE"
    echo "      \"total_size_kb\": $TOTAL_SIZE_KB," >> "$OUTPUT_FILE"
    echo "      \"folders\": [" >> "$OUTPUT_FILE"

    # Add folders to JSON
    first_folder=true
    while IFS='|' read -r size depth path; do
        [[ -z "$size" ]] && continue
        rel_path="${path#$ONEDRIVE_PATH/}"
        escaped_path=$(echo "$rel_path" | sed 's/"/\\"/g')

        if [[ "$first_folder" == "true" ]]; then
            first_folder=false
        else
            echo "," >> "$OUTPUT_FILE"
        fi

        echo -n "        {\"path\": \"$escaped_path\", \"size_kb\": $size, \"depth\": $depth}" >> "$OUTPUT_FILE"
    done < "$TEMP_FILTERED"

    echo "" >> "$OUTPUT_FILE"
    echo "      ]" >> "$OUTPUT_FILE"
    echo -n "    }" >> "$OUTPUT_FILE"

    # Add to summary
    TOTAL_SIZE_MB=$(echo "scale=2; $TOTAL_SIZE_KB/1024" | bc)
    TOTAL_SIZE_GB=$(echo "scale=2; $TOTAL_SIZE_KB/1048576" | bc)

    {
        echo "========================================"
        echo "OneDrive Instance: $instance_name"
        echo "========================================"
        echo "Path: $ONEDRIVE_PATH"
        echo "Total Folders: $TOTAL_FOLDERS"
        echo "Total Size: ${TOTAL_SIZE_KB}KB (${TOTAL_SIZE_MB}MB / ${TOTAL_SIZE_GB}GB)"
        echo ""
        echo "Folders with local storage:"
        printf "%-8s %-12s %-12s %s\n" "DEPTH" "SIZE (KB)" "SIZE (MB)" "PATH"
        echo "--------------------------------------------------------------------------------"

        while IFS='|' read -r size depth path; do
            [[ -z "$size" ]] && continue
            size_mb=$(echo "scale=2; $size/1024" | bc)
            rel_path="${path#$ONEDRIVE_PATH/}"
            printf "%-8s %-12s %-12s %s\n" "$depth" "$size" "${size_mb}MB" "$rel_path"
        done < "$TEMP_FILTERED" | head -50

        if [[ $TOTAL_FOLDERS -gt 50 ]]; then
            echo "  ... (showing first 50 of $TOTAL_FOLDERS folders)"
        fi
        echo ""
    } >> "$SUMMARY_FILE"

    # Cleanup
    rm -f "$TEMP_ALL" "$TEMP_FILTERED" "$TEMP_QUEUE"
done

# Close JSON
echo "" >> "$OUTPUT_FILE"
echo "  ]," >> "$OUTPUT_FILE"
echo "  \"summary\": {" >> "$OUTPUT_FILE"
echo "    \"total_instances\": ${#ONEDRIVE_PATHS[@]}," >> "$OUTPUT_FILE"
echo "    \"total_folders\": $GRAND_TOTAL_FOLDERS," >> "$OUTPUT_FILE"
echo "    \"total_size_kb\": $GRAND_TOTAL_SIZE_KB" >> "$OUTPUT_FILE"
echo "  }" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

# Pretty-print JSON
if command -v python3 &> /dev/null; then
    python3 -m json.tool "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
fi

# Add overall summary
GRAND_SIZE_MB=$(echo "scale=2; $GRAND_TOTAL_SIZE_KB/1024" | bc)
GRAND_SIZE_GB=$(echo "scale=2; $GRAND_TOTAL_SIZE_KB/1048576" | bc)

{
    echo "========================================"
    echo "Overall Summary"
    echo "========================================"
    echo "OneDrive Instances: ${#ONEDRIVE_PATHS[@]}"
    echo "Total Folders with Local Storage: $GRAND_TOTAL_FOLDERS"
    echo "Total Local Storage: ${GRAND_TOTAL_SIZE_KB}KB (${GRAND_SIZE_MB}MB / ${GRAND_SIZE_GB}GB)"
    echo ""
    echo "Note: Only folders using more than ${THRESHOLD_KB}KB are listed."
    echo "      Cloud-only folders (Files On-Demand) are excluded."
} >> "$SUMMARY_FILE"

echo ""
echo "OneDrive state captured successfully!"
echo "JSON output: $OUTPUT_FILE"
echo "Summary: $SUMMARY_FILE"
echo ""
echo "Preview:"
head -40 "$SUMMARY_FILE"
