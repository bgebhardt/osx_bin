#!/bin/bash

# Script to backup non-video and non-audio files while maintaining directory structure
# Usage: ./backup_non_media.sh [source_directory] [backup_directory]

# Set default directories if not provided
SOURCE_DIR="${1:-$(pwd)}"
BACKUP_DIR="${2:-${SOURCE_DIR}/backup_$(date +%Y%m%d_%H%M%S)}"

# Common video and audio file extensions to exclude
EXCLUDE_EXTENSIONS=(
    # Video formats
    "mp4" "mkv" "avi" "mov" "wmv" "flv" "webm" "m4v" "3gp" "ogv"
    "mpg" "mpeg" "m2v" "ts" "mts" "m2ts" "vob" "asf" "rm" "rmvb"
    "divx" "xvid" "f4v" "swf" "qt" "mxf" "dv" "hdmov"
    
    # Audio formats
    "mp3" "wav" "flac" "aac" "ogg" "wma" "m4a" "opus" "aiff" "au"
    "ra" "amr" "3ga" "ac3" "ape" "dts" "m4b" "m4p" "mka" "oga"
    "spx" "tta" "wv" "xm" "it" "s3m" "mod"
)

# Function to check if file extension should be excluded
is_media_file() {
    local file="$1"
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    for exclude_ext in "${EXCLUDE_EXTENSIONS[@]}"; do
        if [[ "$ext" == "$exclude_ext" ]]; then
            return 0  # true - is media file
        fi
    done
    return 1  # false - not media file
}

# Print usage information
print_usage() {
    echo "Usage: $0 [source_directory] [backup_directory]"
    echo ""
    echo "Arguments:"
    echo "  source_directory  : Directory to backup from (default: current directory)"
    echo "  backup_directory  : Directory to backup to (default: source_dir/backup_TIMESTAMP)"
    echo ""
    echo "This script copies all files except common video and audio formats,"
    echo "maintaining the original directory structure."
}

# Check if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    print_usage
    exit 0
fi

# Validate source directory
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Create backup directory if it doesn't exist
if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

echo "Starting backup process..."
echo "Source: $SOURCE_DIR"
echo "Backup: $BACKUP_DIR"
echo ""

# Initialize counters
copied_count=0
skipped_count=0
total_size=0

# Find all files and process them
while IFS= read -r -d '' file; do
    # Skip if it's a directory
    if [[ -d "$file" ]]; then
        continue
    fi
    
    # Get relative path from source directory
    rel_path="${file#$SOURCE_DIR/}"
    
    # Skip if file is in the backup directory (to avoid infinite recursion)
    if [[ "$file" == "$BACKUP_DIR"* ]]; then
        continue
    fi
    
    # Check if it's a media file
    if is_media_file "$file"; then
        echo "Skipping media file: $rel_path"
        ((skipped_count++))
        continue
    fi
    
    # Create destination path
    dest_file="$BACKUP_DIR/$rel_path"
    dest_dir=$(dirname "$dest_file")
    
    # Create destination directory if it doesn't exist
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir"
    fi
    
    # Copy the file
    if cp "$file" "$dest_file"; then
        echo "Copied: $rel_path"
        ((copied_count++))
        
        # Add to total size (in KB)
        file_size=$(du -k "$file" | cut -f1)
        total_size=$((total_size + file_size))
    else
        echo "Error copying: $rel_path"
    fi
    
done < <(find "$SOURCE_DIR" -type f -print0)

echo ""
echo "Backup completed!"
echo "Files copied: $copied_count"
echo "Files skipped (media): $skipped_count"
echo "Total size copied: $(echo "scale=2; $total_size/1024" | bc 2>/dev/null || echo "$total_size KB") MB"
echo "Backup location: $BACKUP_DIR"
