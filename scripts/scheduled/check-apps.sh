#!/bin/bash

# Scheduled every 15 minutes via Lingon X. Similar to cron.
# Schedule the script to run every hour with no output
# 0 * * * * /Users/bryan/bin/scripts/check-apps.sh > /dev/null 2>&1

# Absolute path because launchd PATH is /usr/bin:/bin:/usr/sbin:/sbin (no homebrew).
# Used as a safety wrapper around osascript notifications so a hung notification
# can never block the script (see 2026-04-18 incident with terminal-notifier).
TIMEOUT="/opt/homebrew/bin/timeout"

apps=("OwlOCR" "Hookmark") # moved to Thaw menu bar manager for potential stability improvements
# apps=("Bartender 5" "OwlOCR")
# apps=("Bartender 5" "AnotherApp" "YetAnotherApp")

# OwlOCR seems to exit often.
# Hookmark on Tahoe seems to exit often.
# OneDrive seems to exit often now too. 04-02-2026.

for app in "${apps[@]}"
do
    # Check if the app is running
    if ! pgrep -x "${app}" > /dev/null
    then
        echo "$(date +'%Y-%m-%d %H:%M:%S') - ${app}.app is not running. Starting it now..."
        open -a "${app}"
        # Send a notification that the app is being started
        osascript -e "display notification \"Starting ${app}\" with title \"check-apps.sh\""
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') - ${app}.app is already running."
    fi
done

# Special case: OneDrive runs 2 main processes (one per account: Personal + Work).
# The pgrep pattern uses /MacOS/OneDrive$ to avoid matching "OneDrive Sync Service" or "OneDrive File Provider".
onedrive_count=$(pgrep -xf "/Applications/OneDrive.app/Contents/MacOS/OneDrive" | wc -l | tr -d ' ')
if [ "$onedrive_count" -eq 0 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - OneDrive: no processes running. Restarting..."
    open -a "OneDrive"
    # timeout + & : defensive wrapper after the 2026-04-18 incident where terminal-notifier
    # hung for 15 days, blocking this script. osascript is more reliable but we keep the guard.
    $TIMEOUT 10 osascript -e 'display notification "OneDrive: no processes were running (0/2). Attempted restart." with title "check-apps.sh"' &
elif [ "$onedrive_count" -eq 1 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - OneDrive: only 1/2 processes running. Restarting..."
    open -a "OneDrive"
    $TIMEOUT 10 osascript -e 'display notification "OneDrive: only 1/2 processes running. One account may be down. Attempted restart." with title "check-apps.sh"' &
else
    echo "$(date +'%Y-%m-%d %H:%M:%S') - OneDrive: both processes running (${onedrive_count}/2)."
fi

# open -a "/Applications/Bartender 5.app"

# To run this script every 10 minutes using launchd:
#
# 1. Create a plist file at ~/Library/LaunchAgents/com.user.scriptname.plist
#    (replace "user" with your username and "scriptname" with your script name)
#
# 2. Add the following content to the plist file:
#    <?xml version="1.0" encoding="UTF-8"?>
#    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
#    <plist version="1.0">
#    <dict>
#        <key>Label</key>
#        <string>com.user.scriptname</string>
#        <key>ProgramArguments</key>
#        <array>
#            <string>/path/to/this/script.sh</string>
#        </array>
#        <key>StartInterval</key>z
#        <integer>600</integer>
#        <key>RunAtLoad</key>
#        <true/>
#        <key>StandardErrorPath</key>
#        <string>/tmp/scriptname.err</string>
#        <key>StandardOutPath</key>
#        <string>/tmp/scriptname.out</string>
#    </dict>
#    </plist>
#
# 3. Make sure this script is executable:
#    chmod +x /path/to/this/script.sh
#
# 4. Load the launch agent:
#    launchctl load ~/Library/LaunchAgents/com.user.scriptname.plist
#
# 5. To unload/stop the scheduled execution:
#    launchctl unload ~/Library/LaunchAgents/com.user.scriptname.plist