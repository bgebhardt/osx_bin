#!/bin/bash
# restart-hermes-gateway.sh
# Scheduled daily at 02:00 via LaunchAgent (com.bryan.restart-hermes-gateway).
#
# Purpose:
#   * Proactively restart hermes-gateway to reclaim memory from its slow RSS
#     leak (~20 MiB/hr) and reset any CPU-spinning state before it starves the
#     OrbStack Linux VM's kernel RCU scheduler.
#   * The container has restart: unless-stopped so Docker brings it back
#     automatically after the restart command exits.
#
# Design notes:
#   * launchd PATH is /usr/bin:/bin:/usr/sbin:/sbin (no Homebrew) -> absolute paths.
#   * If OrbStack / Docker is not running, log and exit cleanly -- no alert,
#     since an intentional stop is indistinguishable from a crash at this point.

pick() { for c in "$@"; do [ -x "$c" ] && { printf '%s' "$c"; return 0; }; done; return 1; }
DOCKER="$(pick /opt/homebrew/bin/docker /usr/local/bin/docker "$HOME/.orbstack/bin/docker" /Applications/OrbStack.app/Contents/MacOS/bin/docker)"
TIMEOUT="$(pick /opt/homebrew/bin/timeout /usr/local/bin/timeout /opt/homebrew/bin/gtimeout)"
LOG="$HOME/Library/Logs/restart-hermes-gateway.log"
MAX_LOG_BYTES=524288   # rotate at ~512 KB

ts()  { date +'%Y-%m-%d %H:%M:%S'; }
log() { echo "$(ts) - $*" >>"$LOG"; }

# ---------- log rotation ----------
mkdir -p "$(dirname "$LOG")"
if [ -f "$LOG" ]; then
  sz=$(stat -f%z "$LOG" 2>/dev/null || echo 0)
  [ "$sz" -gt "$MAX_LOG_BYTES" ] && mv -f "$LOG" "$LOG.1"
fi

if [ -z "$DOCKER" ]; then
  log "docker CLI not found -- skipping restart"
  exit 0
fi

# ---------- resolve docker endpoint ----------
if [ -S "$HOME/.orbstack/run/docker.sock" ]; then
  export DOCKER_HOST="unix://$HOME/.orbstack/run/docker.sock"
elif [ ! -S "/var/run/docker.sock" ]; then
  log "docker socket not found -- OrbStack is DOWN/stopped; skipping restart"
  exit 0
fi

# ---------- check docker is responsive ----------
if [ -n "$TIMEOUT" ]; then
  if ! "$TIMEOUT" 15 "$DOCKER" inspect hermes-gateway --format '{{.State.Status}}' >/dev/null 2>&1; then
    log "docker unresponsive or hermes-gateway not found -- skipping restart"
    exit 0
  fi
fi

# ---------- restart ----------
log "daily restart: restarting hermes-gateway (memory leak + CPU-spin mitigation)"
if "$DOCKER" restart hermes-gateway >/dev/null 2>&1; then
  log "hermes-gateway restarted OK"
else
  log "ERROR: docker restart hermes-gateway failed (exit $?)"
fi
