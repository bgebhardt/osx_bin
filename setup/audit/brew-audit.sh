#!/bin/bash

# TODO not working
# A little hacky to get all brew packages from my main 2 install files.
# this isn't working at all as there are a lot of dependencies installed that are not listed in files.

# File paths
BREW_SH="$HOME/bin/setup/homebrew/brew.sh"
BREW_SH2="$HOME/bin/setup/homebrew/brew-cask.sh"
INSTALLED_APPS_LIST="/tmp/installed_apps.txt"
CURRENTLY_INSTALLED_APPS="/tmp/currently_installed_apps.txt"

# Extract installed apps from brew.sh and brew-cask.sh
grep -v '^#' "$BREW_SH" | grep -E "brew install [a-zA-Z0-9_-]+" | awk '{print $3}' > "$INSTALLED_APPS_LIST"
grep -v '^#' "$BREW_SH2" | grep -E "brew install [a-zA-Z0-9_-]+" | awk '{print $3}' > "$INSTALLED_APPS_LIST2"

# Combine the lists from brew.sh and brew-cask.sh into one
cat "$INSTALLED_APPS_LIST2" >> "$INSTALLED_APPS_LIST"

# Get the list of currently installed apps (casks only)
brew list -1 > "$CURRENTLY_INSTALLED_APPS"

# Print out the line count for INSTALLED_APPS_LIST and CURRENTLY_INSTALLED_APPS
echo "Number of apps listed in brew.sh:"
wc -l < "$INSTALLED_APPS_LIST"

echo "Number of currently installed apps:"
wc -l < "$CURRENTLY_INSTALLED_APPS"

# Output apps that are currently installed but not listed in brew.sh
echo -e "\n"
echo "The following apps are currently installed but not listed in brew.sh:"
comm -13 <(sort "$INSTALLED_APPS_LIST") <(sort "$CURRENTLY_INSTALLED_APPS")

# Output apps that are listed in brew.sh but not currently installed
echo -e "\n"
echo "The following apps are listed in brew.sh but not currently installed:"
comm -23 <(sort "$INSTALLED_APPS_LIST") <(sort "$CURRENTLY_INSTALLED_APPS")
