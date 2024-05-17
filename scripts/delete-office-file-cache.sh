#!/bin/bash

# [Clear the Office cache - Office Add-ins | Microsoft Learn](https://learn.microsoft.com/en-us/office/dev/add-ins/testing/clear-cache#clear-the-office-cache-on-mac)
# [Comprehensive Guide To Clear Office Cache on Mac (2023)](https://www.imymac.com/powermymac/clear-office-cache-mac.html#:~:text=Find%20%26%20Delete%20Microsoft%20Office%20Cache%20via%20Finder%2FTerminal,directories%2C%20use%20command-A.%20Click%20command%20delete%20after%20that.)
# [How to clear MS Office cache manually and automatically](https://macpaw.com/how-to/clear-office-cache)
# Try CleanMyMax X?

# Open the Logs Upload folder for the Office apps and delete the logs that are older than X days
# script to check size of folders too
# Consider clearing the cache for the Office apps too

# Cache's folder is typically small

# Important directories
#open ~/Library/Containers/com.microsoft.Excel/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache 
#open ~/Library/Containers/com.microsoft.Excel/Data/Library/Caches
#open ~/Library/Containers/com.microsoft.Excel/Data/Library/Logs/Diagnostics/EXCEL/Upload
 #open ~/Library/Containers/com.microsoft.Excel/Data/tmp

#open ~/Library/Containers/com.microsoft.Word/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache
#open ~/Library/Containers/com.microsoft.Word/Data/Library/Caches
#open ~/Library/Containers/com.microsoft.Word/Data/Library/Logs/Diagnostics/WORD/Upload
# open ~/Library/Containers/com.microsoft.Word/Data/tmp

#open ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache
#open ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Caches
#open ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Logs/Diagnostics/POWERPOINT/Upload
#open ~/Library/Containers/com.microsoft.Powerpoint/Data/tmp

read -p "Do you want calculate cache sizes? (y/n): " choice
if [[ $choice == "y" ]]; then
    # Get the size of each OfficeFileCache directory
    echo "Size of OfficeFileCache and tmp directories:"
    du -sh ~/Library/Containers/com.microsoft.Excel/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache
    du -sh ~/Library/Containers/com.microsoft.Excel/Data/tmp
    du -sh ~/Library/Containers/com.microsoft.Word/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache
    du -sh ~/Library/Containers/com.microsoft.Word/Data/tmp
    du -sh ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache
    du -sh ~/Library/Containers/com.microsoft.Powerpoint/Data/tmp
fi

read -p "Do you want to continue and delete all cache files? (y/n): " choice
if [[ $choice == "n" ]]; then
    exit 0
fi

# Create Trash directories in Trash for the OfficeFileCache and tmp directories to be moved to.
mkdir -p ~/.Trash/Word
mkdir -p ~/.Trash/Excel
mkdir -p ~/.Trash/Powerpoint

# if apps aren't running then move OfficeFileCache to Trash

if pgrep -x "Microsoft Excel" > /dev/null; then
    echo "==> Excel application is running. Skipping cache move."
else
    mv ~/Library/Containers/com.microsoft.Excel/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache ~/.Trash/Excel
    mv ~/Library/Containers/com.microsoft.Excel/Data/tmp ~/.Trash/Excel
    echo "=> Excel files moved to Trash. Check app and then delete trash."
fi

if pgrep -x "Microsoft Word" > /dev/null; then
    echo "==> Word application is running. Skipping cache move."
else
    mv ~/Library/Containers/com.microsoft.Word/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache ~/.Trash/Word
    mv ~/Library/Containers/com.microsoft.Word/Data/tmp ~/.Trash/Word
    echo "=> Word files moved to Trash. Check app and then delete trash."
fi

if pgrep -x "Microsoft PowerPoint" > /dev/null; then
    echo "==> PowerPoint application is running. Skipping cache move."
else
    mv ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache ~/.Trash/Powerpoint
    mv ~/Library/Containers/com.microsoft.Powerpoint/Data/tmp ~/.Trash/PowerPoint
    echo "=> PowerPoint files moved to Trash. Check app and then delete trash."
fi