#!/usr/bin/env bash

# Quick hack to open a new tab in the current tabs directory.

#osascript -e "tell application \"Terminal\" to do script \"cd `pwd`\" in selected tab of window 1"
RUNME="tell application \"Terminal\" to do script \"cd '`pwd`'\" in selected tab of window 1"

osascript -e "tell application \"System Events\" to tell process \"Terminal\" to keystroke \"t\" using command down"
echo "$RUNME"
osascript -e "$RUNME"

echo "New tab DONE"
#echo 'tell application \"Terminal\" to do script \"$RUNME\" in selected tab of window 1'
#osascript -e "tell application \"Terminal\" do script \"$RUNME\" in selected tab of window 1"


