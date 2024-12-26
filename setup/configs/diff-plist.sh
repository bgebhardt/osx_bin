#!/bin/bash
# Compare two plist files using plutil and kdiff3

# Paths to the plist files
plist1_path="$1"
plist2_path="$2"

# Convert plist files to XML format
# Note xml format can express all plist data, which json can not
plutil -convert xml1 -o "${plist1_path}.xml" "$plist1_path"
plutil -convert xml1 -o "${plist2_path}.xml" "$plist2_path"

# Compare the two XML files and output the differences
#diff temp_plist1.xml temp_plist2.xml

# Check if kdiff3 is installed
if ! command -v kdiff3 &> /dev/null
then
    echo "kdiff3 could not be found, please install it to use the GUI comparison."
    exit 1
fi

# Optionally, use kdiff3 to compare the two files in a GUI view
kdiff3 "${plist1_path}.xml" "${plist2_path}.xml"

# Clean up temporary files
#rm "${plist1_path}.xml" "${plist2_path}.xml"

# NOTES
# you can use kdiff3 to compare the two files in a GUI view.
# you can search through the xml plist versions to find the configuration settings and use defaults to set them.
