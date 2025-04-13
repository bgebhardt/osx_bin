#!/bin/bash

# Script to install and schedule my LaunchAgent scripts
# Confirm them in Lingon X

# Define variables
SOURCE_PLIST_DIR="$HOME/bin/scripts/scheduled/LaunchAgents/"
PLIST_DIR="$HOME/Library/LaunchAgents/"

# Create the destination directory if it doesn't exist
mkdir -p "$PLIST_DIR"

# Copy all files from source directory to destination
echo "Copying plist files from $SOURCE_PLIST_DIR to $PLIST_DIR"
cp -f "$SOURCE_PLIST_DIR"/* "$PLIST_DIR" 2>/dev/null || echo "No files to copy or directory is empty"

# Unload and load each com.bryan.* plist file
echo "Loading LaunchAgents..."
for PLIST_FILE in "$PLIST_DIR"com.bryan.*.plist; do
    if [ -f "$PLIST_FILE" ]; then
        echo "Processing $PLIST_FILE"
        launchctl unload "$PLIST_FILE" 2>/dev/null
        launchctl load -w "$PLIST_FILE"
        echo "Loaded $PLIST_FILE"
    fi
done

# TODO: confirm script files exist and are executable

echo "Successfully scheduled all scripts."