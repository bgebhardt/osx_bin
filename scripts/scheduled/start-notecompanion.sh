#!/bin/bash

# Script to start the NoteCompanion web app
# NoteCompanion is an AI assistant for Obsidian that goes beyond just a chat.
# see [different-ai/note-companion: Note Companion: AI assistant for Obsidian that goes beyond just a chat. (prev File Organizer 2000)](https://github.com/different-ai/note-companion/tree/master)

if [ ! -d "/Users/bryan/code/personal/note-companion/packages/web" ]; then
    echo "Error: note-companion not found at /Users/bryan/code/personal/note-companion/packages/web"
    osascript -e 'display notification "note-companion not found at /Users/bryan/code/personal/note-companion/packages/web" with title "Start NoteCompanion"'
    exit 1
fi
cd /Users/bryan/code/personal/note-companion/packages/web || exit
export PATH="/usr/local/bin:/opt/homebrew/bin/:$PATH"
# pnpm build:self-host # uncomment this if you need to make a newer build
pnpm start


# Tried doing this as a launch agent but it was failing. So this is set up to be managed by PM2.
# requires pm2 installed like so: 
# npm install -g pm2

# Start with PM2:
# cd /path/to/note-companion/packages/web
# pnpm build:self-host
# pm2 start ~/bin/scripts/scheduled/note-companion-pm2.config.js
# pm2 save
# pm2 startup

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