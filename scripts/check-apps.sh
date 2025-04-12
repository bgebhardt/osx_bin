#!/bin/bash

apps=("Bartender 5")
# apps=("Bartender 5" "AnotherApp" "YetAnotherApp")

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