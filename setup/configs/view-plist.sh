#!/bin/bash
# view plist in xml

# Function to display usage information
usage() {
    echo "Usage: $0 [-a app_name] [plist_path]"
    echo "  -a app_name   Specify the application name to find its plist file"
    echo "  plist_path    Path to the plist file to be processed"
    exit 1
}

# Check if no arguments are passed
if [ $# -eq 0 ]; then 
    echo "No arguments provided" 
    usage
fi

# Initialize variables
plist_path=""
app_name=""

# Function to find the preference file for a given app name
find_app_plist() {
    app_name="$1"
    app_id=$(/usr/bin/osascript -e "id of app \"$app_name\"")

    if [ $? -ne 0 ]; then
        echo "Error: Failed to get app ID for $app_name"
        exit 1
    fi
    
    #plist_path=$(find ~/Library/Preferences -name "*${app_name}*.plist" 2>/dev/null | head -n 1)
    #echo "App $app_name has and id of $app_id" # for debugging
    local result="$HOME/Library/Preferences/${app_id}.plist"
    echo "$result"    
}

# Parse options
while getopts "a:" opt; do
    case $opt in
        a)
            app_name=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

plist_path=$(find_app_plist "$app_name")

# set the plist path to the last remaining argument
for arg in "$@"; do 
    #echo "Remaining argument: $arg"
    plist_path="$arg"
done

echo "Processing file: $plist_path"

# Check if a valid plist file is passed in
if [ ! -f "$plist_path" ]; then
    echo "Error: File not found!"
    exit 1
fi

if [[ "$plist_path" != *.plist ]]; then
    echo "Error: Not a plist file!"
    exit 1
fi

# Convert plist files to XML format
# Note xml format can express all plist data, which json can not
#plutil -convert xml1 -o "${plist1_path}.xml" "$plist1_path"

# Save the output to a file in the same directory as where script was run
output_path="$(pwd)/$(basename "${plist_path}").xml"

# Print out where the file is written
echo "Output file written to: $output_path"

plutil -convert xml1 -o "$output_path" "$plist_path"

# open in default editor (preferring code if it is there)
# this is a quick hack because "code -w" for some reason didn't work for the EDITOR clause. Likely a bug I need to fix.
if command -v code &> /dev/null; then
    code "$output_path"
elif [ -n "$EDITOR" ]; then
    "$EDITOR" "$output_path"
else
    open "$output_path"
fi
