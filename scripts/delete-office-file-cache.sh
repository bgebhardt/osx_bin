#!/bin/bash

# [Clear the Office cache - Office Add-ins | Microsoft Learn](https://learn.microsoft.com/en-us/office/dev/add-ins/testing/clear-cache#clear-the-office-cache-on-mac)
# [Comprehensive Guide To Clear Office Cache on Mac (2023)](https://www.imymac.com/powermymac/clear-office-cache-mac.html#:~:text=Find%20%26%20Delete%20Microsoft%20Office%20Cache%20via%20Finder%2FTerminal,directories%2C%20use%20command-A.%20Click%20command%20delete%20after%20that.)
# [How to clear MS Office cache manually and automatically](https://macpaw.com/how-to/clear-office-cache)
# Try CleanMyMax X?

# Open the Logs Upload folder for the Office apps and delete the logs that are older than X days
# script to check size of folders too
# Consider clearing the cache for the Office apps too

# Important directories
#open ~/Library/Containers/com.microsoft.Excel/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache 
#open ~/Library/Containers/com.microsoft.Excel/Data/Library/Caches
#open ~/Library/Containers/com.microsoft.Excel/Data/Library/Logs/Diagnostics/EXCEL/Upload

#open ~/Library/Containers/com.microsoft.Word/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache
#open ~/Library/Containers/com.microsoft.Word/Data/Library/Caches
#open ~/Library/Containers/com.microsoft.Word/Data/Library/Logs/Diagnostics/WORD/Upload

#open ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Application\ Support/Microsoft/AppData/Microsoft/Office/16.0/OfficeFileCache
#open ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Caches
#open ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Logs/Diagnostics/POWERPOINT/Upload

# Define the number of days
days=28

# Calculate the sizes of files older than the specified number of days
du_output_word=$(find ~/Library/Containers/com.microsoft.Word/Data/Library/Logs/Diagnostics/WORD/Upload -type f -mtime +$days -exec du -cm {} + | grep total$)
if [ -z "$du_output_word" ]; then
    du_output_word=0
fi

du_output_excel=$(find ~/Library/Containers/com.microsoft.Excel/Data/Library/Logs/Diagnostics/EXCEL/Upload -type f -mtime +$days -exec du -cm {} + | grep total$)
if [ -z "$du_output_excel" ]; then
    du_output_excel=0
fi

du_output_powerpoint=$(find ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Logs/Diagnostics/POWERPOINT/Upload -type f -mtime +$days -exec du -cm {} + | grep total$)
if [ -z "$du_output_powerpoint" ]; then
    du_output_powerpoint=0
fi

# Extract the sizes from the du output
size_word=$(echo "$du_output_word" | awk '{print $1}')
size_excel=$(echo "$du_output_excel" | awk '{print $1}')
size_powerpoint=$(echo "$du_output_powerpoint" | awk '{print $1}')

# Convert sizes to human readable format
size_word_human=$(find ~/Library/Containers/com.microsoft.Word/Data/Library/Logs/Diagnostics/WORD/Upload -type f -mtime +$days -exec du -ch {} + | grep total$ | awk '{print $1}')
size_excel_human=$(find ~/Library/Containers/com.microsoft.Excel/Data/Library/Logs/Diagnostics/EXCEL/Upload -type f -mtime +$days -exec du -ch {} + | grep total$ | awk '{print $1}')
size_powerpoint_human=$(find ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Logs/Diagnostics/POWERPOINT/Upload -type f -mtime +$days -exec du -ch {} + | grep total$ | awk '{print $1}')


echo "Size of Word files older than $days days: $size_word ($size_word_human)"
echo "Size of Excel files older than $days days: $size_excel ($size_excel_human)"
echo "Size of PowerPoint files older than $days days: $size_powerpoint ($size_powerpoint_human)"

# Calculate the total disk space used for the three find commands
total_disk_space=$(($size_word + $size_excel + $size_powerpoint))
total_disk_space_gb=$(echo "scale=2; $total_disk_space / 1024" | bc)

echo "Total disk space used of office log files older than $days: $total_disk_space ($total_disk_space_gb GB)"

read -p "Do you want to delete all files older than $days days? (y/n): " answer
if [ "$answer" = "y" ]; then
    find ~/Library/Containers/com.microsoft.Word/Data/Library/Logs/Diagnostics/WORD/Upload -type f -mtime +$days -delete
    find ~/Library/Containers/com.microsoft.Excel/Data/Library/Logs/Diagnostics/EXCEL/Upload -type f -mtime +$days -delete
    find ~/Library/Containers/com.microsoft.Powerpoint/Data/Library/Logs/Diagnostics/POWERPOINT/Upload -type f -mtime +$days -delete
    echo "Files older than $days days have been deleted."
else
    echo "No files were deleted."
fi