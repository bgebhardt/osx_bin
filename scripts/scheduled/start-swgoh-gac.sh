#!/bin/bash

# Script to start/stop the SWGOH Grand Arena Championship automation script
# Assumes the script is located at /Users/bryan/code/personal/swgoh/grand-arena-automation/run.sh
# and that it is executable
# SWGOH Grand Arena Championship automation is a github project located at:
# https://github.com/bgebhardt/swgoh.git
#
# Usage:
#   start-swgoh-gac.sh start    # Start the GAC script
#   start-swgoh-gac.sh stop     # Stop the GAC script

SCRIPT_DIR="/Users/bryan/code/personal/swgoh/grand-arena-automation"
SCRIPT_NAME="run-grand-arena-automation.sh"
LOG_FILE="/tmp/swgoh-gac.log"
PID_FILE="/tmp/swgoh-gac.pid"

start_gac() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "GAC script is already running (PID: $PID)"
            return 1
        fi
    fi

    cd "$SCRIPT_DIR" || exit 1
    chmod +x "$SCRIPT_NAME"
    ./"$SCRIPT_NAME" > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    echo "GAC script started (PID: $!)"
}

stop_gac() {
    if [ ! -f "$PID_FILE" ]; then
        echo "No PID file found. GAC script may not be running."
        return 1
    fi

    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        kill "$PID"
        rm "$PID_FILE"
        echo "GAC script stopped (PID: $PID)"
    else
        echo "GAC script is not running (stale PID file removed)"
        rm "$PID_FILE"
    fi
}

case "${1:-start}" in
    start)
        start_gac
        ;;
    stop)
        stop_gac
        ;;
    restart)
        stop_gac
        sleep 1
        start_gac
        ;;
    status)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if ps -p "$PID" > /dev/null 2>&1; then
                echo "GAC script is running (PID: $PID)"
            else
                echo "GAC script is not running (stale PID file exists)"
            fi
        else
            echo "GAC script is not running"
        fi
        ;;
    help|-h|--help)
        echo "SWGOH Grand Arena Championship automation script manager"
        echo ""
        echo "Usage: $0 {start|stop|restart|status|help}"
        echo ""
        echo "Commands:"
        echo "  start    Start the GAC script (default if no argument)"
        echo "  stop     Stop the GAC script"
        echo "  restart  Stop and then start the GAC script"
        echo "  status   Check if the GAC script is running"
        echo "  help     Show this help message"
        echo ""
        echo "Files:"
        echo "  Script: $SCRIPT_DIR/$SCRIPT_NAME"
        echo "  Log:    $LOG_FILE"
        echo "  PID:    $PID_FILE"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|help}"
        exit 1
        ;;
esac
