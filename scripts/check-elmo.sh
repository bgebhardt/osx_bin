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
# this isn't the most accurate way to check location.

# Get the postal code based on the current IP address
ip_response=$(curl -s ipinfo.io/json)
postal_code=$(echo "$ip_response" | jq -r '.postal')
org=$(echo "$ip_response" | jq -r '.org')

# Check if the organization is "AS7922 Comcast Cable Communications, LLC"
if [[ "$org" == "AS7922 Comcast Cable Communications, LLC" ]]; then
    echo "The organization is AS7922 Comcast Cable Communications, LLC"
else
    echo "The organization is $org (which is wrong so not checking)"
    exit 0
fi

# Check if we are in postal code "94536" (where I live); but not specific enough
if [[ "$postal_code" == "95103" ]]; then
    echo "We are in postal code 95103"
else
    echo "We are not in postal code 94536, we are in postal code $postal_code"
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

# Correct Example: the json response from ipinfo.io is:
# {
#   "ip": "98.42.139.237",
#   "hostname": "c-98-42-139-237.hsd1.ca.comcast.net",
#   "city": "San Jose",
#   "region": "California",
#   "country": "US",
#   "loc": "37.3394,-121.8950",
#   "org": "AS7922 Comcast Cable Communications, LLC",
#   "postal": "95103",
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

