#!/bin/bash

# Script to open all file paths in Mac Finder
# Usage: ./open_in_finder.sh [path_to_file_containing_paths]

# Default file name if no argument provided
FILE_PATH="${1:-file_paths.txt}"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' not found!"
    echo "Usage: $0 [path_to_file_containing_paths]"
    exit 1
fi

echo "Opening paths from '$FILE_PATH' in Finder..."

# Counter for tracking
opened_count=0
failed_count=0

# Read file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines
    if [ -z "$line" ]; then
        continue
    fi
    
    # Remove trailing whitespace and newlines
    path=$(echo "$line" | sed 's/[[:space:]]*$//')
    
    # Check if path exists
    if [ -e "$path" ]; then
        echo "Opening: $path"
        open "$path"
        ((opened_count++))
        
        # Small delay to prevent overwhelming the system
        sleep 0.1
    else
        echo "Warning: Path does not exist: $path"
        ((failed_count++))
    fi
    
done < "$FILE_PATH"

echo ""
echo "Summary:"
echo "  Successfully opened: $opened_count paths"
echo "  Failed (path not found): $failed_count paths"
echo "Done!"