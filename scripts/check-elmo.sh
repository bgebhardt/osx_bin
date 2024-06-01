#!/bin/bash

# Script to check if Elmo TM and Elmo disks are connected.

# Scheduled every hour via Lingon X. Similar to cron.
# Schedule the script to run every hour with no output
# 0 * * * * /Users/bryan/bin/scripts/check-elmo.sh > /dev/null 2>&1

# TODO check for my Elmo disk container being mounted first
# Checking if on power or battery as a quick hack to check if I'm at home or not
# Check if the system is on power or battery
if [[ $(pmset -g batt | grep -c "AC Power") -gt 0 ]]; then
    echo "System is on power"
else
    echo "System is on battery"
    exit 0
fi

# Check if "Elmo" disk is mounted
if mount | grep -q "Elmo"; then
    echo "Elmo disk is connected"
    # Add code here to display a notification

    # if Elmo is mounted check if Elmo TM is mounted

    # Check if "Elmo TM" disk is mounted
    if ! mount | grep -q "Elmo TM"; then
        echo "Elmo TM disk is not connected"
        # Add code here to display a notification
        osascript -e 'display notification "Elmo TM disk is not connected. Reconnect to resume TM backups." with title "Disk Notification"'
    else
        echo "Elmo TM disk is connected"
    fi

else
    echo "Elmo disk is not connected"
fi

