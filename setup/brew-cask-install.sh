#!/bin/bash
# This script reads lines from a file and uses them as arguments for brew install
# Usage: ./brew-cask-install.sh filename

# Check if a filename is provided
if [ -z "$1" ]; then
  echo "Please provide a filename as an argument"
  exit 1
fi

# Make sure we’re using the latest Homebrew.
brew update


# Loop through each line of the file
while IFS= read -r line; do
  # Skip empty lines or comments
  if [ -z "$line" ] || [[ "$line" == \#* ]]; then
    continue
  fi
  # Call brew install with the line as an argument
  brew install --cask "$line"
done < "$1"

# Remove outdated versions from the cellar.
brew cleanup
