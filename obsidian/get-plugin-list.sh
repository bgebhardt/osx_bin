#!/bin/bash

# write a bash script that goes through the ".obidian/plugins" directory and pulls the following information from the manifest.json file of each plugin. Write to a file the following info from the manifest file - name, version, description, authorURL, and helpURL

# The manifest file looks like
# {
#   "id": "dataview",
#   "name": "Dataview",
#   "version": "0.5.68",
#   "minAppVersion": "0.13.11",
#   "description": "Complex data views for the data-obsessed.",
#   "author": "Michael Brenan <blacksmithgu@gmail.com>",
#   "authorUrl": "https://github.com/blacksmithgu",
#   "helpUrl": "https://blacksmithgu.github.io/obsidian-dataview/",
#   "isDesktopOnly": false
# }

# Define the plugins directory
#plugins_dir="$HOME/.obsidian/plugins"
plugins_dir=".obsidian/plugins"
output_file="obsidian_plugins.csv"

# Function to display help message
show_help() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo "Lists Obsidian plugins and writes information to a file."
    echo ""
    echo "Options:"
    echo "  -d, --dir DIR    Specify the plugins directory (default: $plugins_dir)"
    echo "  -o, --output FILE Output file name (default: $output_file)"
    echo "  -h, --help       Display this help message and exit"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            plugins_dir="$2"
            shift 2
            ;;
        -o|--output)
            output_file="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Please install jq first:"
    echo "  - For macOS: brew install jq"
    echo "  - For Ubuntu/Debian: sudo apt install jq"
    echo "  - For CentOS/RHEL: sudo yum install jq"
    exit 1
fi

# Check if plugins directory exists
if [ ! -d "$plugins_dir" ]; then
    echo "Error: Plugins directory not found at $plugins_dir"
    exit 1
fi

# Start the output file with a header
echo "# Obsidian Plugins" > "$output_file"
echo "Generated on $(date)" >> "$output_file"

# Initialize a counter for the plugins
plugin_count=0

echo "" >> "$output_file"

echo "" >> "$output_file"
# echo "| Name | Version | Description | Author URL | Help URL |" >> "$output_file"
# echo "| ---- | ------- | ----------- | ---------- | -------- |" >> "$output_file"

# Write CSV header
echo "\"Name\",\"Version\",\"Description\",\"Author URL\",\"Help URL\"" >> "$output_file"
#echo ""Name", "Version", "Description", "Author URL", "Help URL"" >> "$output_file"

# Loop through each plugin directory
for plugin_dir in "$plugins_dir"/*; do
    if [ -d "$plugin_dir" ]; then
        ((plugin_count++))
        manifest_file="$plugin_dir/manifest.json"
        
        if [ -f "$manifest_file" ]; then
            # Extract information from manifest.json
            name=$(jq -r '.name // "N/A"' "$manifest_file")
            version=$(jq -r '.version // "N/A"' "$manifest_file")
            description=$(jq -r '.description // "N/A"' "$manifest_file")
            author_url=$(jq -r '.authorUrl // "N/A"' "$manifest_file")
            help_url=$(jq -r '.helpUrl // "N/A"' "$manifest_file")
            
            # Write to output file in markdown table format
            # Format URLs as markdown links if they're not N/A
            # if [ "$author_url" != "N/A" ]; then
            #     author_url="[$author_url]($author_url)"
            # fi
            # if [ "$help_url" != "N/A" ]; then
            #     help_url="[$help_url]($help_url)"
            # fi
            
            # Write to output file in markdown table format
            # echo "| $name | $version | $description | $author_url | $help_url |" >> "$output_file"

            # Write to output file in csv format
            echo "\"$name\",\"$version\",\"$description\",\"$author_url\",\"$help_url\"" >> "$output_file"
        fi
    fi
done

# Add the count to the output file
echo "" >> "$output_file"
echo "Total plugins: $plugin_count" >> "$output_file"

echo "Plugin information has been written to $output_file"