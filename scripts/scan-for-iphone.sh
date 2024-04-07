#!/bin/sh
# Script inspired and written by Bing Chat.
# Note: this requires root access to run arp-scan.

# Using [Lingon - Peter Borg Apps](https://www.peterborgapps.com/lingon/) to schedule the job.
# Created an app that runs the script. That seems to work best. 
# Notifications are not displayed when run as a job but are when run as an app.
# Alternate: Run as a job that runs as root every hour to make sure my iPhone is connected to the same network.
# requires full paths to work.

# TODO: add error checking for arp-scan, file existence, etc.

# Path to the file containing the iPhone MAC address
# Store in file so we don't check in to git
MAC_ADDRESS_FILE="/Users/bryan/bin/scripts/iphone_mac_address.txt"

# Check if the MAC address file exists
if [ ! -f "$MAC_ADDRESS_FILE" ]; then
  echo "Error: MAC address file not found."
  exit 1
fi

# Read the MAC address from the file
IPHONE_MAC=$(cat "$MAC_ADDRESS_FILE")


# Check if arp-scan is installed
#if ! command -v arp-scan &> /dev/null; then
#  echo "Error: arp-scan not installed. Please install it and try again."
#  exit 1
#fi

echo "Scanning for iPhone with MAC address: $IPHONE_MAC"

# Scan the local network and store the results
#SCAN_RESULTS=$(/opt/homebrew/bin/arp-scan --localnet)

# this will prompt for password; commented out so sript must be run as root. Kept as reference
SCAN_RESULTS=$(sudo /opt/homebrew/bin/arp-scan --localnet)

# Check for sudo or other failure (no output means sudo failed)
#if [ -z "$SCAN_RESULTS" ]; then
#  echo "Error: Failed to run arp-scan. Please run the script with sudo."
#  exit 1
#fi

# Check if the iPhone's MAC address is in the results
if echo "$SCAN_RESULTS" | grep -q "You don't have permission"; then
  echo "Error: Failed to run arp-scan. Please run the script with sudo."
  # Display a dialog if the iPhone is detected - for debugging only
  osascript -e 'tell app "System Events" to display dialog "echo "Error: Failed to run arp-scan. Please run the script with sudo."'
fi

# Check if the iPhone's MAC address is in the results
if echo "$SCAN_RESULTS" | grep -q "$IPHONE_MAC"; then
  echo "Your iPhone is connected to the same Wi-Fi network."
  # Display a dialog if the iPhone is detected - for debugging only
  osascript -e 'tell app "System Events" to display dialog "Your iPhone is detected on the same Wi-Fi network."'  
else
  echo "Your iPhone is not detected on the same Wi-Fi network."
  # Display a Mac notification if the iPhone is not detected (doesn't work when run as a root job)
  #osascript -e 'display notification "Your iPhone is not detected on the same Wi-Fi network." with title "Network Check"'
  # Display a dialog if the iPhone is not detected
  osascript -e 'tell app "System Events" to display dialog "Your iPhone is not detected on the same Wi-Fi network."'  
fi

echo "Scan complete."

# Other options were nmap [nmap - Detect if iPhone is active on network - Super User](https://superuser.com/questions/877266/detect-if-iphone-is-active-on-network)
