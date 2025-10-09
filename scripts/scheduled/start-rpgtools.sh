#!/bin/bash

# Script to start the 5etools automation script
# Assumes the script is located at /Users/bryan/code/personal/rpg-tools/run-5etools/start-5etools.sh
# and that it is executable
# 5etools is a github project located at:
# https://github.com/5etools/5etools.git

SCRIPT_DIR="/Users/bryan/code/personal/rpg-tools/run-5etools"
SCRIPT_NAME="start-5etools.sh"
LOG_FILE="/tmp/5etools.log"

cd "$SCRIPT_DIR" || exit 1
chmod +x "$SCRIPT_NAME"
./"$SCRIPT_NAME" > "$LOG_FILE" 2>&1 &