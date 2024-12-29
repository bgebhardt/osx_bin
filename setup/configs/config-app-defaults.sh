#!/bin/bash
# Script to set default applications for file types in macOS using the duti command line tool

# see [moretension/duti: A command-line tool to select default applications for document types and URL schemes on Mac OS X](https://github.com/moretension/duti) for more info and docs

# example of checking a file type
# duti -x jpg

# # Output
# Preview
# /Applications/Preview.app
# com.apple.Preview

# example: Set Finder as the default handler for ftp:// URLs:
# duti -s com.apple.Finder ftp

# Common file types to consider:
# video: Common video formats (mp4, avi, mkv, etc.)
# audio: Audio formats (mp3, wav, aac, etc.)
# image: Image formats (jpg, png, gif, etc.)
# code: Programming and markup files (py, js, rs, etc.)
# archive: Archive formats (zip, tar, gz, etc.)

# TIP: Getting list of UTI's (from duti man page)

# first you need to enable the locate and wait for it to finish indexing
#sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

# Then...
# To get a list of UTIs on your system, you can use the following command line:
#$(locate lsregister) -dump | grep '[[:space:]]uti:' | awk '{ print $2 }' | sort | uniq

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
duti -s net.sourceforge.skim-app.skim com.adobe.pdf
#duti -s com.apple.Preview com.adobe.pdf

# Set default image viewer to Preview
#echo "Setting default image viewer to Preview"
#duti -s com.apple.Preview public.image

# Set default video player to VLC
#echo "Setting default video player to VLC"
#duti -s org.videolan.vlc public.movie
#duti -s org.videolan.vlc public.video

echo "Default applications have been set."


