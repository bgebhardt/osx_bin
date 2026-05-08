#!/bin/bash

# Scheduled every 15 minutes via LaunchAgent (com.bryan.check-onedrive).
# Split out from check-apps.sh so OneDrive monitoring can be enabled/disabled independently.

# Absolute path because launchd PATH is /usr/bin:/bin:/usr/sbin:/sbin (no homebrew).
# Used as a safety wrapper around osascript notifications so a hung notification
# can never block the script (see 2026-04-18 incident with terminal-notifier).
TIMEOUT="/opt/homebrew/bin/timeout"

# OneDrive runs 2 main processes (one per account: Personal + Work).
# The pgrep pattern uses the full MacOS/OneDrive path to avoid matching
# "OneDrive Sync Service" or "OneDrive File Provider".
onedrive_count=$(pgrep -xf "/Applications/OneDrive.app/Contents/MacOS/OneDrive" | wc -l | tr -d ' ')
if [ "$onedrive_count" -eq 0 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - OneDrive: no processes running. Restarting..."
    open -a "OneDrive"
    # timeout + & : defensive wrapper after the 2026-04-18 incident where terminal-notifier
    # hung for 15 days, blocking this script. osascript is more reliable but we keep the guard.
    $TIMEOUT 10 osascript -e 'display notification "OneDrive: no processes were running (0/2). Attempted restart." with title "check-onedrive.sh"' &
elif [ "$onedrive_count" -eq 1 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - OneDrive: only 1/2 processes running. Restarting..."
    open -a "OneDrive"
    $TIMEOUT 10 osascript -e 'display notification "OneDrive: only 1/2 processes running. One account may be down. Attempted restart." with title "check-onedrive.sh"' &
else
    echo "$(date +'%Y-%m-%d %H:%M:%S') - OneDrive: both processes running (${onedrive_count}/2)."
fi
