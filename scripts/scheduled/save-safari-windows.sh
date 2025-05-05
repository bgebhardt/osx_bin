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
OUTPUT_DIR="/Users/bryan/safari_windows"
# Create the directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/${DAY_OF_WEEK}_hour_${CURRENT_HOUR}.txt"

# Check if Safari is running through System Events and save result to a variable
SAFARI_RUNNING=$(osascript -e 'tell application "System Events" to (name of processes) contains "Safari"')

# If Safari is not running (result is "false"), exit
if [[ "$SAFARI_RUNNING" != "true" ]]; then
    echo "Safari is not running. No tabs saved. Exiting."
    exit 0
fi

# Get the list of open Finder windows using osascript
osascript << EOF > "$OUTPUT_FILE"
tell application "Safari"
    set tabList to ""
    set windowCount to count of windows
    repeat with i from 1 to windowCount
        set currentWindow to window i
        set tabCount to count of tabs of currentWindow
        set tabList to tabList & "WINDOW " & i & "\n"
        repeat with j from 1 to tabCount
            set currentTab to tab j of currentWindow
            set tabURL to URL of currentTab
            set tabName to name of currentTab
            set tabList to tabList & tabName & " - " & tabURL & "\n"
        end repeat
    end repeat
    return tabList
end tell
EOF

echo "Open Safari tabs saved to $OUTPUT_FILE"