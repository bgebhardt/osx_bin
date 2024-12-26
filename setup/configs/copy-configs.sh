#!/bin/bash

# Script in progress to copy config directories via rsync
# Not working in current setup though as rsync not working.

# Check if the source Mac hostname and username are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <source_mac_hostname> <username>"
    exit 1
fi

SOURCE_MAC=$1
USERNAME=$2
DEST_DIR="$HOME/$SOURCE_MAC"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Directories to copy
DIRECTORIES=(
    ".config"
    "Library/Preferences"
    "Library/Application Support"
)

# Copy the config directories
for DIR in "${DIRECTORIES[@]}"; 
do
    rsync -avz --progress "$USERNAME@$SOURCE_MAC:~/$DIR/" "$DEST_DIR/$DIR/"
done

echo "Configuration files copied to $DEST_DIR"