#!/bin/bash
# Script to install and start the note-companion service with PM2

# Ensure pm2 is installed
if ! command -v pm2 &> /dev/null; then
    echo "PM2 not found. Installing globally..."
    npm install -g pm2
fi

# Set up note companion with PM2
APP_DIR="$HOME/code/personal/note-companion/packages/web"

# Check if the app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo "Directory $APP_DIR does not exist. Please clone or set up your note-companion app."
    exit 1
fi

cd "$APP_DIR"
pm2 start ~/bin/scripts/scheduled/note-companion-pm2.config.js
pm2 save
pm2 startup

echo "note-companion service installed and started with PM2."

# Other useful PM2 commands

# Managing the Service
# Check if it's running:
# pm2 list

# Stop the service:
# pm2 stop note-companion

# View logs:
# bash# For launch agent:
# pm2 logs note-companion

# Restart the service:
# pm2 restart note-companion