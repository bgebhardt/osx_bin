#!/bin/bash

# Script to start the SWGOH Grand Arena Championship automation script
# Assumes the script is located at /Users/bryan/code/personal/swgoh/grand-arena-automation/run.sh
# and that it is executable
# SWGOH Grand Arena Championship automation is a github project located at:
# https://github.com/bgebhardt/swgoh.git

SCRIPT_DIR="/Users/bryan/code/personal/swgoh/grand-arena-automation"
SCRIPT_NAME="run.sh"
LOG_FILE="/tmp/swgoh-gac.log"

cd "$SCRIPT_DIR" || exit 1
chmod +x "$SCRIPT_NAME"
./"$SCRIPT_NAME" > "$LOG_FILE" 2>&1 &
