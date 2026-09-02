#!/bin/bash

# restart-karabiner.sh
#
# Restarts the Karabiner-Elements HID pipeline by kickstarting its two
# system daemons: the Core-Service (event grabber/remapper) and the
# VirtualHIDDevice-Daemon (the virtual keyboard/pointing device all input
# is routed through).
#
# Useful when the trackpad/scrolling or keyboard input becomes laggy or
# unresponsive after sleep, a display change, or a software update -- the
# event pipeline can get into a stale state that a clean daemon restart clears.
#
# Requires sudo (the daemons live in the system domain).

set -euo pipefail

CORE="org.pqrs.service.daemon.Karabiner-Core-Service"
VHID="org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon"

# Re-exec with sudo if not already root, preserving any passed args.
if [ "$(id -u)" -ne 0 ]; then
    echo "Restarting Karabiner daemons (requires sudo)..."
    exec sudo "$0" "$@"
fi

echo "==> Kickstarting $CORE"
launchctl kickstart -k "system/$CORE"

echo "==> Kickstarting $VHID"
launchctl kickstart -k "system/$VHID"

# Give the daemons a moment to come back up.
sleep 2

echo "==> Running Karabiner processes:"
ps -Ao pid,%cpu,comm | grep -i karabiner | grep -vi grep || echo "  (none found)"

echo "Done. Test your trackpad/keyboard now."

# EOF
