#!/bin/bash

# Script to save the list of open Finder windows to a file
# This script is scheduled to run every hour using Lingon X
# This will allow me to remember open windows when the finder loses them.

# Scheduled every hour via Lingon X. Similar to cron.
# Schedule the script to run every hour with no output
# 0 * * * * /Users/bryan/bin/scripts/save-finder-windows.sh > /dev/null 2>&1

# Get the current hour (24-hour format)
CURRENT_HOUR=$(date +"%H")
DAY_OF_WEEK=$(date +"%a")

# Define the output file path
# Get the current day of the week and format the output file
OUTPUT_DIR="/tmp/finder_windows"
# Create the directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/${DAY_OF_WEEK}_hour_${CURRENT_HOUR}.txt"

# Get the list of open Finder windows using osascript
osascript << EOF > "$OUTPUT_FILE"
tell application "Finder"
    set windowList to ""
    set windowCount to count of windows
    repeat with i from 1 to windowCount
        try
            set currentWindow to window i
            set targetPath to (POSIX path of (target of currentWindow as alias))
            set windowList to windowList & targetPath & "\n"
        on error
            # Skip windows without valid targets
        end try
    end repeat
    return windowList
end tell
EOF

echo "Open Finder windows saved to $OUTPUT_FILE"