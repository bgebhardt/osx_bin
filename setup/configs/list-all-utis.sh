#!/bin/bash
# Getting list of UTI's (from duti man page)

# Command will get all the claimed UTI's - a lot of output!
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump  | grep 'uti:' | awk '{ print $2 }' | sort | uniq

# see [moretension/duti: A command-line tool to select default applications for document types and URL schemes on Mac OS X](https://github.com/moretension/duti) for more info and docs

# example of checking a file type
# duti -x jpg

# # Output
# Preview
# /Applications/Preview.app
# com.apple.Preview

# example: Set Finder as the default handler for ftp:// URLs:
# duti -s com.apple.Finder ftp

# -d <uti> lists the default handler; example: duti -d public.html
# -l <uti> lists all registered handlers. example: duti -l public.html

# Common file types to consider:
# video: Common video formats (mp4, avi, mkv, etc.)
# audio: Audio formats (mp3, wav, aac, etc.)
# image: Image formats (jpg, png, gif, etc.)
# code: Programming and markup files (py, js, rs, etc.)
# archive: Archive formats (zip, tar, gz, etc.)

# not working from man page
# /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump  | grep '[[:space:]]uti:' | awk '{ print $2 }' | sort | uniq

# Pages with good advice for looking up UTI's for apps and for listing them all.
# * [macos - How to get a file's UTI from the command line in Mac OS X? - Super User](https://superuser.com/questions/209145/how-to-get-a-files-uti-from-the-command-line-in-mac-os-x)
# * [macos - Is it possible to query the launch services database for applications that will open an arbitrary file or UTI type? - Super User](https://superuser.com/questions/323599/is-it-possible-to-query-the-launch-services-database-for-applications-that-will)

#$(locate lsregister) -dump | grep '[[:space:]]uti:' | awk '{ print $2 }' | sort | uniq
# locate is not working on my mac so can't find lsregister

# first you need to enable the locate and wait for it to finish indexing
#sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

# Then...
# To get a list of UTIs on your system, you can use the following command line:
#$(locate lsregister) -dump | grep '[[:space:]]uti:' | awk '{ print $2 }' | sort | uniq