#!/bin/bash
# Script to set default applications for file types in macOS using the duti command line tool

# see [moretension/duti: A command-line tool to select default applications for document types and URL schemes on Mac OS X](https://github.com/moretension/duti) for more info and docs

# example of checking a file type
# duti -x jpg

# # Output
# Preview
# /Applications/Preview.app
# com.apple.Preview

# to get the id of an App use osascript like this
# osascript -e 'id of app "Skim"'

# example: Set Finder as the default handler for ftp:// URLs:
# duti -s com.apple.Finder ftp

# you can pass the role to set as follows
# duti -s com.sindresorhus.velja public.html <role>

# Valid roles are defined as follows:
#        all                application handles all roles for the given UTI.
#        viewer             application handles reading and displaying documents with the given UTI.
#        editor             application can manipulate and save the item. Implies viewer.
#        shell              application can execute the item.
#        none               application cannot open the item, but provides an icon for the given UTI

# -d <uti> lists the default handler; example: duti -d public.html
# -l <uti> lists all registered handlers. example: duti -l public.html

# Common file types to consider:
# video: Common video formats (mp4, avi, mkv, etc.)
# audio: Audio formats (mp3, wav, aac, etc.)
# image: Image formats (jpg, png, gif, etc.)
# code: Programming and markup files (py, js, rs, etc.)
# archive: Archive formats (zip, tar, gz, etc.)

# Tip: Command will get all the claimed UTI's - a lot of output! see other script for this
# /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump  | grep 'uti:' | awk '{ print $2 }' | sort | uniq

# Check if duti is installed
if ! command -v duti &> /dev/null
then
    echo "duti could not be found, please install it first."
    exit 1
fi

# Set default web browser to Edge
echo "Setting default web browser to Velja"
duti -s com.sindresorhus.velja public.html all

# Set default email client to Microsoft Outlook
echo "Setting default email client to Microsoft Outlook"
duti -s com.microsoft.Outlook mailto

# Set default text editor to Visual Studio Code
echo "Setting default shell editor to Visual Studio Code"
#duti -s com.microsoft.VSCode public.plain-text
#duti -s com.microsoft.VSCode public.unix-executable
duti -s com.microsoft.VSCode public.shell-script

# Set default PDF viewer to Skim
echo "Setting default PDF viewer to Skim"
duti -s net.sourceforge.skim-app.skim pdf all
#duti -s com.apple.Preview pdf all # set back to Preview

# Set default image viewer to Preview
#echo "Setting default image viewer to Preview"
#duti -s com.apple.Preview public.image

# Set default video player to VLC
#echo "Setting default video player to VLC"
#duti -s org.videolan.vlc public.movie
#duti -s org.videolan.vlc public.video

# Set default csv viewer to Excel
echo "Setting default PDF viewer to Excel"
duti -s com.microsoft.Excel csv all

# Set default mp4 viewer to Elmedia Player
echo "Setting default mp4 viewer to Elmedia Player"
duti -s com.Eltima.ElmediaPlayer mp4 all

# Set default mkv viewer to Elmedia Player
echo "Setting default mkv viewer to Elmedia Player"
duti -s com.Eltima.ElmediaPlayer mkv all

echo "Default applications have been set."
