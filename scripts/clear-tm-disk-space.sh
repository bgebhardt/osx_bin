#!/bin/bash

# Set the path to the Time Machine local snapshots
snapshot_path="/Volumes/com.apple.TimeMachine.localsnapshots"

# This command is using the `tmutil` tool on MacOS to thin local snapshots. The command takes three arguments:
# 1. `/`: This specifies the directory where the local snapshots are stored.
# 2. `20000000000`: This specifies the target size in bytes that the local snapshots should be thinned to. In this case, it is 20,000,000,000 bytes (approximately 20 GB).
# 3. `4`: When purge_amount and urgency are specified, tmutil will attempt (with urgency level 1-4) to reclaim purge_amount in bytes by thinning snapshots. (or could it be: This specifies the minimum number of local snapshots to keep. In this case, it is set to 4.)

# Therefore, the command `tmutil thinlocalsnapshots / 20000000000 4` will thin the local snapshots stored in the root directory to a target size of 20 GB while keeping a minimum of 4 snapshots.

# List the number of local snapshots
snapshot_count=$(tmutil listlocalsnapshots / | wc -l)
echo "PRE: Number of Time Machine local snapshots: $snapshot_count"

# Check if the snapshot path exists
if [ -d "$snapshot_path" ]; then
    # Remove all local snapshots
    tmutil thinlocalsnapshots / 20000000000 4
    echo "Time Machine local disk space thinned successfully."
else
    echo "Time Machine local snapshots path not found."
fi

# List the number of local snapshots
snapshot_count=$(tmutil listlocalsnapshots / | wc -l)
echo "POST: Number of Time Machine local snapshots: $snapshot_count"

# Check if "Elmo TM" disk is mounted; often time it is not mounted and local snapshots are piling up.
if ! mount | grep -q "Elmo TM"; then
    echo "IMPORTANT: Elmo TM disk is not connected. Reconnect it to continue Time Machine backups."
    # Add code here to display a notification
    osascript -e 'display notification "Elmo TM disk is not connected" with title "Disk Notification"'
fi

