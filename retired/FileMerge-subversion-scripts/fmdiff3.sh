#!/bin/sh

#
# Wrapper script to use FileMerge as a diff3-cmd in Subversion
#

FM="/Xcode3/Developer/Applications/Utilities/FileMerge.app/Contents/MacOS/FileMerge"
FMDIFF="$(basename $0)"
GN="/usr/local/bin/growlnotify"

while [ $# != 0 ]; do
	case $1 in
		-m)
			merged=1
		;;
		-E)
			notall=1
		;;
		-L)
			shift
			if [ -z "$rightlabel" ]; then
				rightlabel=$1
			elif [ -z "$ancestorlabel" ]; then
				ancestorlabel=$1
			elif [ -z "$leftlabel" ]; then
				leftlabel=$1
			else
				echo "Too many labels" 1>&2
				exit 2
			fi
		;;
		-*)
			echo "Unknown option: $1" 1>&2
			exit 1
		;;
		*)
			if [ -z "$rightfile" ]; then
				rightfile=$1
			elif [ -z "$ancestorfile" ]; then
				ancestorfile=$1
			elif [ -z "$leftfile" ]; then
				leftfile=$1
			else
				echo "Too many files to diff" 1>&2
				exit 2
			fi
	esac
	shift
done

if [ -z "$rightfile" ] || [ -z "$ancestorfile" ] || [ -z "$leftfile" ]; then
	echo "Usage: $0 [options] myfile oldfile yourfile" 1>&2
	exit 2
fi
if [ -z "$merged" ]; then
	echo "Can only output merged file (need -m option)" 1>&2
	exit 2
fi

mergefile=`mktemp -t fmdiff3`

function labels {
	[ -n "$ancestorlabel"  ] && echo Ancestor: $ancestorlabel
	[ -n "$leftlabel"      ] && echo     Left: $leftlabel
	[ -n "$rightlabel"     ] && echo    Right: $rightlabel
}

echo Starting FileMerge... 1>&2
labels 1>&2
if [ -x "$GN" ]; then
	labels | "$GN" -n "$FMDIFF" "Starting FileMerge"
fi

"$FM" -left "$leftfile" -right "$rightfile" \
	-ancestor "$ancestorfile" -merge "$mergefile"

cat "$mergefile" && rm "$mergefile"
