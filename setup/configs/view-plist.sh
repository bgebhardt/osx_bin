#!/bin/bash
# view plist in xml

# Paths to the plist files
plist1_path="$1"

# Check if a valid plist file is passed in
if [ ! -f "$plist1_path" ]; then
    echo "Error: File not found!"
    exit 1
fi

if [[ "$plist1_path" != *.plist ]]; then
    echo "Error: Not a plist file!"
    exit 1
fi

# Convert plist files to XML format
# Note xml format can express all plist data, which json can not
#plutil -convert xml1 -o "${plist1_path}.xml" "$plist1_path"

# Save the output to a file in the same directory as where script was run
output_path="$(pwd)/$(basename "${plist1_path}").xml"

# Print out where the file is written
echo "Output file written to: $output_path"

plutil -convert xml1 -o "$output_path" "$plist1_path"

# open in default editor (preferring code if it is there)
# this is a quick hack because "code -w" for some reason didn't work for the EDITOR clause. Likely a bug I need to fix.
if command -v code &> /dev/null; then
    code "$output_path"
elif [ -n "$EDITOR" ]; then
    "$EDITOR" "$output_path"
else
    open "$output_path"
fi
