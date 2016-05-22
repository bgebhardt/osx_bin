#!/bin/sh

# script that takes in a index number of a finder window
#  and returns the path to that window.

# set default winNum to 1
winNum=1

# too many arguements is an error
if  [ $# -gt 1 ]; then
	echo "Usage: $0 [index number of finder window]"
	echo " If no finder window provided, then frontmost is assumed."
	exit 1

# if just 1 arguement then set the winNum
elif [ $# -eq 1 ] ; then
	winNum=$1
fi

winPath=`osascript -e "tell application \"Finder\" to get POSIX path of (target of Finder window $winNum as alias)"`

echo "$winPath"

#osascript -e "tell application \"Finder\" to get POSIX path of (target of Finder window $winNum as alias)"

