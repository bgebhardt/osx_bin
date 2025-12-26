#!/bin/bash

# OneDrive Local Storage Audit Script
# Finds all folders using more than 100KB of local storage
# Helps identify what's pinned as "Always keep on this device"

# Configuration
ONEDRIVE_PATH="$HOME/OneDrive"
THRESHOLD_KB=100
OUTPUT_FILE="$HOME/onedrive_audit_$(date +%Y%m%d_%H%M%S).txt"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=================================================="
echo "OneDrive Local Storage Audit"
echo "=================================================="
echo "Scanning: $ONEDRIVE_PATH"
echo "Threshold: ${THRESHOLD_KB}KB ($(echo "scale=2; $THRESHOLD_KB/1024" | bc)MB)"
echo "Output file: $OUTPUT_FILE"
echo ""

# Check if OneDrive folder exists
if [ ! -d "$ONEDRIVE_PATH" ]; then
    echo -e "${RED}Error: OneDrive folder not found at $ONEDRIVE_PATH${NC}"
    exit 1
fi

echo "Scanning all subdirectories (this may take a few minutes)..."
echo ""

# Create temporary file for processing
TEMP_FILE=$(mktemp)

# Scan all directories recursively and get sizes in KB
du -sk "$ONEDRIVE_PATH"/* 2>/dev/null | while read size path; do
    if [ "$size" -gt "$THRESHOLD_KB" ]; then
        echo "$size|$path"
    fi
done | sort -t'|' -k1 -rn > "$TEMP_FILE"

# Also scan second-level directories for better granularity
find "$ONEDRIVE_PATH" -mindepth 1 -maxdepth 2 -type d 2>/dev/null | while read dir; do
    size=$(du -sk "$dir" 2>/dev/null | cut -f1)
    if [ "$size" -gt "$THRESHOLD_KB" ]; then
        echo "$size|$dir"
    fi
done | sort -t'|' -k1 -rn >> "$TEMP_FILE"

# Remove duplicates and sort
sort -t'|' -k1 -rn -u "$TEMP_FILE" > "${TEMP_FILE}.sorted"
mv "${TEMP_FILE}.sorted" "$TEMP_FILE"

# Count results
TOTAL_FOLDERS=$(wc -l < "$TEMP_FILE" | tr -d ' ')
TOTAL_SIZE_KB=0

# Display results and write to file
{
    echo "=================================================="
    echo "OneDrive Local Storage Audit Report"
    echo "Generated: $(date)"
    echo "=================================================="
    echo ""
    echo "Folders using more than ${THRESHOLD_KB}KB of local storage:"
    echo ""
    printf "%-12s %-12s %s\n" "SIZE (KB)" "SIZE (MB)" "PATH"
    echo "------------------------------------------------------------"
} | tee "$OUTPUT_FILE"

# Process and display results
while IFS='|' read -r size path; do
    size_mb=$(echo "scale=2; $size/1024" | bc)
    size_gb=$(echo "scale=2; $size/1048576" | bc)
    
    TOTAL_SIZE_KB=$((TOTAL_SIZE_KB + size))
    
    # Determine display format based on size
    if [ "$size" -gt 1048576 ]; then
        # > 1GB, show in GB
        printf "%-12s %-12s %s\n" "${size}" "${size_gb}GB" "$path"
    elif [ "$size" -gt 1024 ]; then
        # > 1MB, show in MB
        printf "%-12s %-12s %s\n" "${size}" "${size_mb}MB" "$path"
    else
        # Show in KB
        printf "%-12s %-12s %s\n" "${size}" "${size}KB" "$path"
    fi
done < "$TEMP_FILE" | tee -a "$OUTPUT_FILE"

# Calculate totals
TOTAL_SIZE_MB=$(echo "scale=2; $TOTAL_SIZE_KB/1024" | bc)
TOTAL_SIZE_GB=$(echo "scale=2; $TOTAL_SIZE_KB/1048576" | bc)

{
    echo ""
    echo "------------------------------------------------------------"
    echo "Summary:"
    echo "  Total folders found: $TOTAL_FOLDERS"
    echo "  Total local storage: ${TOTAL_SIZE_KB}KB (${TOTAL_SIZE_MB}MB / ${TOTAL_SIZE_GB}GB)"
    echo ""
    echo "Report saved to: $OUTPUT_FILE"
    echo "=================================================="
} | tee -a "$OUTPUT_FILE"

# Cleanup
rm -f "$TEMP_FILE"

# Terminal summary with colors
echo ""
echo -e "${GREEN}Scan complete!${NC}"
echo -e "${BLUE}Found $TOTAL_FOLDERS folders using more than ${THRESHOLD_KB}KB${NC}"
echo -e "${YELLOW}Total local storage: ${TOTAL_SIZE_GB}GB${NC}"
echo ""
echo "To free up space, right-click folders in Finder and select 'Free up space'"
EOF

chmod +x ~/onedrive_storage_audit.sh
echo "Script created at: ~/onedrive_storage_audit.sh"