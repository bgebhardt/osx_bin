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

# Function to check if we are in the home location based on postal code
check_home_location() {
    # Get the postal code based on the current IP address
    local ip_response
    local postal_code
    local error_reason
    local shortcuts_response

    # Great link that suggested using shortcut to get location. I created a "Get Current Location" shortcut.
    # [macos - Is there a way to access a Mac's geolocation from terminal? - Ask Different](https://apple.stackexchange.com/questions/60152/is-there-a-way-to-access-a-macs-geolocation-from-terminal)

    # This is a link to the Get Current Location shortcut you need to install for this script to work.
    # https://www.icloud.com/shortcuts/d2a71cc565344ce9abdce7cb0f585795

    if ! shortcuts_response=$(shortcuts run "Get Current Location" 2>&1); then
        echo "Error running shortcut: $shortcuts_response"
    elif [[ "$shortcuts_response" == *"error"* ]]; then
        echo 'Get the "Get Current Location" shortcut at https://www.icloud.com/shortcuts/d2a71cc565344ce9abdce7cb0f585795'
        echo "Error in shortcuts response: $shortcuts_response"
    else
        postal_code=$(echo "$shortcuts_response" | grep "CA" | awk '{print $NF}')
    fi

    # disabled now
    # Try ipapi.co first (but it can get rate limited)
    # ip_response=$(curl -s https://ipapi.co/json)
    # error_reason=$(echo "$ip_response" | jq -r '.reason')

    # if [[ "$error_reason" == "RateLimited" ]]; then
    #     echo "Error: ipapi.co rate limited. TODO: Falling back to ipinfo.io"
    #     # doesn't work great because zipcode returned is wrong
    #     # Fall back to ipinfo.io if rate limited
    #     ip_response=$(curl -s ipinfo.io/json)
    #     exit 1
    # fi
    # postal_code=$(echo "$ip_response" | jq -r '.postal')
    
    # Check if we are in postal code "94536" (where I live)
    if [[ "$postal_code" == "94536" ]]; then
        echo "We are in postal code 94536"
        return 0  # We are home
    else
        echo "We are not in postal code 94536, we are in postal code $postal_code"
        return 1  # We are not home
    fi
}

# Call the function and exit if we're not home
if ! check_home_location; then
    exit 0
fi

# Check if "Elmo" disk is mounted
if mount | grep -q "Elmo"; then
    echo "Elmo disk is connected"
    # Add code here to display a notification

    # if Elmo is mounted check if Elmo TM is mounted

    # Check if "Elmo TM" disk is mounted
    if ! mount | grep "Elmo TM"; then
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

# using "tmutil latestbackup -t" check the last time machine backup. It returns a date and time in this format "2025-04-20-122633"

# display a notification if the last backup is older than 1 day. In the notification include the time of the last backup and how long its been since a complete backup.

# Check the last Time Machine backup using tmutil
echo "Checking latest Time Machine backup with tmutil..."
latest_backup=$(/usr/bin/tmutil latestbackup -t 2>/dev/null)

if [ -n "$latest_backup" ]; then
    echo "Last Time Machine backup timestamp: $latest_backup"
    
    # Parse the date format (2025-04-20-122633)
    year=${latest_backup:0:4}
    month=${latest_backup:5:2}
    day=${latest_backup:8:2}
    hour=${latest_backup:11:2}
    minute=${latest_backup:13:2}
    second=${latest_backup:15:2}
    
    # Format for date command
    formatted_date="${year}-${month}-${day} ${hour}:${minute}:${second}"
    
    # Convert to seconds since epoch
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS date command syntax
        backup_seconds=$(date -j -f "%Y-%m-%d %H:%M:%S" "$formatted_date" +%s)
    else
        # Linux date command syntax
        backup_seconds=$(date -d "$formatted_date" +%s)
    fi
    
    # Current time in seconds
    current_seconds=$(date +%s)
    
    # Calculate difference
    seconds_diff=$((current_seconds - backup_seconds))
    days_diff=$((seconds_diff / 86400))
    hours_diff=$(( (seconds_diff % 86400) / 3600 ))
    
    echo "Time since last backup: $days_diff days and $hours_diff hours"
    
    # Format a readable date for the notification
    readable_date=$(date -j -f "%Y-%m-%d %H:%M:%S" "$formatted_date" "+%b %d, %Y at %I:%M %p")
    
    # Check if backup is older than 1 day
    if [ "$days_diff" -gt 1 ]; then 
        echo "Time Machine backup is overdue"
        if [ "$days_diff" -eq 1 ]; then
            time_ago="$days_diff day and $hours_diff hours"
        else
            time_ago="$days_diff days and $hours_diff hours"
        fi

        osascript -e "display notification \"Last backup was on $readable_date ($time_ago ago). Please check your backup drive.\" with title \"Time Machine Backup Overdue\""
        
    else
        echo "Time Machine backup is current (less than a day old)"
    fi
else
    echo "Could not determine the latest Time Machine backup"
    #osascript -e 'display notification "Unable to determine last backup time. Please check Time Machine." with title "Time Machine Status Unknown"'
    #osascript -e "display notification \"Unable to determine last backup time. Returned $latest_backup.\" with title \"Time Machine Status Unknown\""
fi

# Example: the json response from ipapi.co is:
# curl -s https://ipapi.co/json
# {
#     "ip": "2601:646:9900:fd40:75d2:3b9a:7e3b:9c17",
#     "network": "2601:646:9900:8000::/49",
#     "version": "IPv6",
#     "city": "Fremont",
#     "region": "California",
#     "region_code": "CA",
#     "country": "US",
#     "country_name": "United States",
#     "country_code": "US",
#     "country_code_iso3": "USA",
#     "country_capital": "Washington",
#     "country_tld": ".us",
#     "continent_code": "NA",
#     "in_eu": false,
#     "postal": "94536",
#     "latitude": 37.5625,
#     "longitude": -122.0004,
#     "timezone": "America/Los_Angeles",
#     "utc_offset": "-0700",
#     "country_calling_code": "+1",
#     "currency": "USD",
#     "currency_name": "Dollar",
#     "languages": "en-US,es-US,haw,fr",
#     "country_area": 9629091.0,
#     "country_population": 327167434,
#     "asn": "AS7922",
#     "org": "COMCAST-7922"
# }

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