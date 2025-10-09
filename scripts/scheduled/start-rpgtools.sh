#!/bin/bash

# Script to start/stop the 5etools automation script
# Assumes the script is located at /Users/bryan/code/personal/rpg-tools/run-5etools/start-5etools.sh
# and that it is executable
# 5etools is a github project located at:
# https://github.com/5etools/5etools.git
#
# Usage:
#   start-rpgtools.sh start    # Start the 5etools script
#   start-rpgtools.sh stop     # Stop the 5etools script

SCRIPT_DIR="/Users/bryan/code/personal/rpg-tools/run-5etools"
SCRIPT_NAME="start-5etools.sh"
LOG_FILE="/tmp/5etools.log"
PID_FILE="/tmp/5etools.pid"

start_rpgtools() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "5etools script is already running (PID: $PID)"
            return 1
        fi
    fi

    cd "$SCRIPT_DIR" || exit 1
    chmod +x "$SCRIPT_NAME"
    ./"$SCRIPT_NAME" > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    echo "5etools script started (PID: $!)"
}

stop_rpgtools() {
    if [ ! -f "$PID_FILE" ]; then
        echo "No PID file found. 5etools script may not be running."
        return 1
    fi

    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        kill "$PID"
        rm "$PID_FILE"
        echo "5etools script stopped (PID: $PID)"
    else
        echo "5etools script is not running (stale PID file removed)"
        rm "$PID_FILE"
    fi
}

case "${1:-start}" in
    start)
        start_rpgtools
        ;;
    stop)
        stop_rpgtools
        ;;
    restart)
        stop_rpgtools
        sleep 1
        start_rpgtools
        ;;
    status)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if ps -p "$PID" > /dev/null 2>&1; then
                echo "5etools script is running (PID: $PID)"
            else
                echo "5etools script is not running (stale PID file exists)"
            fi
        else
            echo "5etools script is not running"
        fi
        ;;
    help|-h|--help)
        echo "5etools automation script manager"
        echo ""
        echo "Usage: $0 {start|stop|restart|status|help}"
        echo ""
        echo "Commands:"
        echo "  start    Start the 5etools script (default if no argument)"
        echo "  stop     Stop the 5etools script"
        echo "  restart  Stop and then start the 5etools script"
        echo "  status   Check if the 5etools script is running"
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