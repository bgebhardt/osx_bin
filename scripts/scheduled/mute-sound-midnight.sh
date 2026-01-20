#!/bin/bash

# Script to mute system sound at midnight
# This ensures sound is muted while sleeping
# Scheduled to run at midnight every night via LaunchAgent

# Mute the system volume
osascript -e "set volume with output muted"

# Log the action
echo "$(date): System sound muted" >> /tmp/mute-sound-midnight.log
