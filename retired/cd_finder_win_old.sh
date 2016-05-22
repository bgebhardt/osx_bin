#!/bin/sh

# script that prints out the list of finder windows and prompt the user
# for which one they want to cd to.

# relies on list_finder_window.scpt AppleScript.

osascript ~/bin/list_finder_windows.scpt

echo -n "Pick a number> "
read number

# just returns the path
winPath=`osascript -e "tell application \"Finder\" to get POSIX path of (target of Finder window $number as alias)"`

#echo "Path = $winPath"
#cd "$winPath"  # doesn't work.  needs to change the parent's directory.

