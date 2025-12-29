#!/bin/bash

# OneDrive Local Storage Audit Script
# Finds all folders using more than 100KB of local storage
# Scans up to 8 levels deep to identify specific local folders
# Helps identify what's pinned as "Always keep on this device"

# Configuration
ONEDRIVE_PATH="$HOME/OneDrive"
THRESHOLD_KB=50
MAX_DEPTH=4
OUTPUT_FILE="$HOME/onedrive_audit_$(date +%Y%m%d_%H%M%S).txt"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo "=================================================="
echo "OneDrive Local Storage Audit"
echo "=================================================="
echo "Scanning: $ONEDRIVE_PATH"
echo "Max depth: $MAX_DEPTH levels"
echo "Threshold: ${THRESHOLD_KB}KB ($(echo "scale=2; $THRESHOLD_KB/1024" | bc)MB)"
echo "Output file: $OUTPUT_FILE"
echo ""

# Check if OneDrive folder exists
if [ ! -d "$ONEDRIVE_PATH" ]; then
    echo -e "${RED}Error: OneDrive folder not found at $ONEDRIVE_PATH${NC}"
    exit 1
fi

echo "Scanning all subdirectories up to $MAX_DEPTH levels deep (this may take several minutes)..."
echo ""

# Create temporary files for processing
TEMP_ALL=$(mktemp)
TEMP_FILTERED=$(mktemp)
TEMP_QUEUE=$(mktemp)

# Recursive scanning function
# Drills down into folders with local storage to find the most specific ones
scan_directory() {
    local dir="$1"
    local current_depth="$2"

    # Get size of this directory
    local size
    size=$(du -sk "$dir" 2>/dev/null | cut -f1)

    # Skip if below threshold (cloud-only)
    if [ -z "$size" ] || [ "$size" -le "$THRESHOLD_KB" ]; then
        return
    fi

    # If we're at max depth, record this folder and stop
    if [ "$current_depth" -ge "$MAX_DEPTH" ]; then
        echo "$size|$current_depth|$dir" >> "$TEMP_ALL"
        return
    fi

    # This folder has local storage (> threshold)
    # Check subdirectories to see if we should drill deeper
    local subdirs_with_storage
    local subdirs_below_threshold
    subdirs_with_storage=$(mktemp)
    subdirs_below_threshold=$(mktemp)

    # Get list of subdirectories first (avoid subshell issue)
    local subdirs_list
    subdirs_list=$(mktemp)
    find -L "$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null > "$subdirs_list"

    # Check each subdir
    while read -r subdir; do
        local subdir_size
        subdir_size=$(du -sk "$subdir" 2>/dev/null | cut -f1)

        if [ -n "$subdir_size" ]; then
            if [ "$subdir_size" -gt "$THRESHOLD_KB" ]; then
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
    [ -s "$subdirs_with_storage" ] && num_with_storage=$(wc -l < "$subdirs_with_storage" | tr -d ' ')
    [ -s "$subdirs_below_threshold" ] && num_below_threshold=$(wc -l < "$subdirs_below_threshold" | tr -d ' ')

    local total_subdirs=$((num_with_storage + num_below_threshold))

    # Decision logic:
    # - If no subdirs have storage: this is a leaf folder, record it
    # - If 90%+ of subdirs have storage: mostly populated, record it and stop
    # - If fewer than 90% have storage: mixed content, drill deeper
    if [ "$num_with_storage" -eq 0 ]; then
        # No subdirs with local storage - this is a leaf folder
        echo "$size|$current_depth|$dir" >> "$TEMP_ALL"
    elif [ "$total_subdirs" -gt 0 ]; then
        # Calculate percentage: (num_with_storage * 100) / total_subdirs
        local percentage=$((num_with_storage * 100 / total_subdirs))

        if [ "$percentage" -ge 90 ]; then
            # 90%+ of subdirs have local storage - consider this fully populated
            echo "$size|$current_depth|$dir" >> "$TEMP_ALL"
        else
            # Less than 90% - mixed content, drill deeper into subdirs with storage
            while read -r subdir; do
                echo "$subdir|$((current_depth + 1))" >> "$TEMP_QUEUE"
            done < "$subdirs_with_storage"
        fi
    fi

    rm -f "$subdirs_with_storage" "$subdirs_below_threshold" "$subdirs_list"
}

echo "Phase 1: Scanning directory tree (skipping cloud-only folders)..."

# Start with level 1 directories
find -L "$ONEDRIVE_PATH" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r dir; do
    echo "$dir|1" >> "$TEMP_QUEUE"
done

total_scanned=0
# Process queue
while [ -s "$TEMP_QUEUE" ]; do
    # Read one entry from queue
    if read -r line; then
        IFS='|' read -r dir depth <<< "$line"
        scan_directory "$dir" "$depth"
        total_scanned=$((total_scanned + 1))

        # Show full path
        echo -ne "\r  Scanned $total_scanned directories... $dir\033[K"
    fi < "$TEMP_QUEUE"

    # Remove processed line from queue
    tail -n +2 "$TEMP_QUEUE" > "${TEMP_QUEUE}.tmp" && mv "${TEMP_QUEUE}.tmp" "$TEMP_QUEUE"
done

echo -ne "\r  Scanning complete! Scanned $total_scanned directories.                                                      \n"

# Sort results by depth (ascending) then size (descending) for display
sort -t'|' -k2 -n -k1 -rn "$TEMP_ALL" > "$TEMP_FILTERED"

# Count results
TOTAL_FOLDERS=$(wc -l < "$TEMP_FILTERED" | tr -d ' ')
TOTAL_SIZE_KB=0

# Display results and write to file
{
    echo "=================================================="
    echo "OneDrive Local Storage Audit Report"
    echo "Generated: $(date)"
    echo "=================================================="
    echo ""
    echo "Showing most specific folders with more than ${THRESHOLD_KB}KB local storage"
    echo "(Drilled down until finding folders with no local subfolders)"
    echo ""
    printf "%-8s %-12s %-12s %s\n" "DEPTH" "SIZE (KB)" "SIZE (MB/GB)" "PATH"
    echo "--------------------------------------------------------------------------------"
} | tee "$OUTPUT_FILE"

# Calculate totals first (before the display loop)
TOTAL_SIZE_KB=0
while IFS='|' read -r size depth path; do
    TOTAL_SIZE_KB=$((TOTAL_SIZE_KB + size))
done < "$TEMP_FILTERED"

TOTAL_SIZE_MB=$(echo "scale=2; $TOTAL_SIZE_KB/1024" | bc)
TOTAL_SIZE_GB=$(echo "scale=2; $TOTAL_SIZE_KB/1048576" | bc)

# Process and display results with hierarchy awareness
current_depth=0
while IFS='|' read -r size depth path; do
    size_mb=$(echo "scale=2; $size/1024" | bc)
    size_gb=$(echo "scale=2; $size/1048576" | bc)

    # Add separator when depth changes
    if [ "$depth" -ne "$current_depth" ]; then
        if [ "$current_depth" -ne 0 ]; then
            echo "" | tee -a "$OUTPUT_FILE"
        fi
        current_depth=$depth
    fi

    # Get relative path for better readability
    rel_path="${path#"$ONEDRIVE_PATH"/}"

    # Determine display format based on size
    if [ "$size" -gt 1048576 ]; then
        # > 1GB, show in GB
        printf "%-8s %-12s %-12s %s\n" "$depth" "$size" "${size_gb}GB" "$rel_path"
    elif [ "$size" -gt 1024 ]; then
        # > 1MB, show in MB
        printf "%-8s %-12s %-12s %s\n" "$depth" "$size" "${size_mb}MB" "$rel_path"
    else
        # Show in KB
        printf "%-8s %-12s %-12s %s\n" "$depth" "$size" "${size}KB" "$rel_path"
    fi
done < "$TEMP_FILTERED" | tee -a "$OUTPUT_FILE"

{
    echo ""
    echo "--------------------------------------------------------------------------------"
    echo "Summary:"
    echo "  Total leaf folders found: $TOTAL_FOLDERS"
    echo "  Total local storage: ${TOTAL_SIZE_KB}KB (${TOTAL_SIZE_MB}MB / ${TOTAL_SIZE_GB}GB)"
    echo ""
    echo "Note: Each folder shown is the most specific location with local storage."
    echo "      Algorithm drilled down until finding folders with only cloud-only subfolders."
    echo ""
    echo "Report saved to: $OUTPUT_FILE"
    echo "=================================================="
} | tee -a "$OUTPUT_FILE"

# Cleanup
rm -f "$TEMP_ALL" "$TEMP_FILTERED" "$TEMP_QUEUE"

# Terminal summary with colors
echo ""
echo -e "${GREEN}Scan complete!${NC}"
echo -e "${BLUE}Found $TOTAL_FOLDERS leaf folders using more than ${THRESHOLD_KB}KB${NC}"
echo -e "${YELLOW}Total local storage: ${TOTAL_SIZE_GB}GB${NC}"
echo ""
echo -e "${CYAN}To free up space:${NC}"
echo "  1. Right-click folders in Finder and select 'Free up space'"
echo "  2. Or use OneDrive settings to change sync preferences"