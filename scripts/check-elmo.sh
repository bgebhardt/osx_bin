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

# Check the location of this MacOS

# Get the postal code based on the current IP address
postal_code=$(curl -s ipinfo.io/json | jq -r '.postal')

# Check if we are in postal code "94536" (where I live)
if [[ "$postal_code" == "94536" ]]; then
    echo "We are in postal code 94536"
else
    echo "We are not in postal code 94536"
    exit 0
fi

# Example: the json response from ipinfo.io is:
# {
#   "ip": "173.196.200.3",
#   "hostname": "syn-173-196-200-003.biz.spectrum.com",
#   "city": "Arcadia",
#   "region": "California",
#   "country": "US",
#   "loc": "34.1397,-118.0353",
#   "org": "AS20001 Charter Communications Inc",
#   "postal": "91066",
#   "timezone": "America/Los_Angeles",
#   "readme": "https://ipinfo.io/missingauth"
# }

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
    # Add code here to display a notification
    osascript -e 'display notification "Elmo disk is not connected. Reconnect it." with title "Disk Notification"'
fi

