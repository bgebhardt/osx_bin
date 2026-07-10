#!/bin/bash

# check-docker-mem.sh
# Scheduled every 15 minutes via LaunchAgent (com.bryan.check-docker-mem).
#
# Purpose:
#   * Record per-container memory usage from `docker stats` so we can see WHICH
#     container is eating the OrbStack VM's memory over time.
#   * Fire a macOS notification when total container memory reaches
#     THRESHOLD_PCT of the VM's total memory -- the exact condition that
#     preceded the Docker freezes on 7/7 and 7/9 (guest kernel VM_FAULT_OOM).
#   * Also notify if Docker is UNREACHABLE or FROZEN (docker call times out),
#     since a wedged OrbStack is the failure we care about most.
#
# Design notes (learned the hard way):
#   * launchd PATH is /usr/bin:/bin:/usr/sbin:/sbin (no Homebrew) -> absolute paths.
#   * Every docker call is wrapped in `timeout`; a frozen OrbStack makes docker
#     hang forever, so a hang is treated as an alertable condition, not a block.
#   * Notifications use osascript wrapped in `timeout ... &` per the 2026-04-18
#     incident where terminal-notifier hung for 15 days and blocked a script.
#   * Set CDM_NOTIFY=0 in the environment to suppress notifications (for testing).

# ---------- config ----------
# Resolve binaries from known locations. launchd has a minimal PATH, and the
# docker CLI lives in different places per machine: /usr/local/bin on the
# MacBook Pro, /opt/homebrew/bin on the M4, or ~/.orbstack/bin under OrbStack.
pick() { for c in "$@"; do [ -x "$c" ] && { printf '%s' "$c"; return 0; }; done; return 1; }
DOCKER="$(pick /opt/homebrew/bin/docker /usr/local/bin/docker "$HOME/.orbstack/bin/docker" /Applications/OrbStack.app/Contents/MacOS/bin/docker)"
TIMEOUT="$(pick /opt/homebrew/bin/timeout /usr/local/bin/timeout /opt/homebrew/bin/gtimeout)"
OSASCRIPT="/usr/bin/osascript"

THRESHOLD_PCT=90          # alert when containers use >= this % of VM memory
DOCKER_TIMEOUT=30         # seconds before a docker call is treated as "frozen"
ALERT_COOLDOWN=7200       # min seconds between repeat notifications (2h)
MAX_LOG_BYTES=1048576     # rotate the log at ~1 MB

LOG="$HOME/Library/Logs/check-docker-mem.log"
STATE="$HOME/Library/Logs/check-docker-mem.state"
LOCK="/tmp/check-docker-mem.lock"

# ---------- helpers ----------
ts()  { date +'%Y-%m-%d %H:%M:%S'; }
log() { echo "$(ts) - $*" >>"$LOG"; }

run_docker() {
  # Wrap docker in `timeout` (when present) so a frozen engine can't hang us.
  if [ -n "$TIMEOUT" ]; then "$TIMEOUT" "$DOCKER_TIMEOUT" "$DOCKER" "$@"; else "$DOCKER" "$@"; fi
}

notify() {
  # $1 = message. Guarded so a hung notification can never block the script.
  [ "${CDM_NOTIFY:-1}" = "0" ] && { log "notify suppressed (CDM_NOTIFY=0): $1"; return; }
  local msg="${1//\"/\\\"}"
  "$TIMEOUT" 10 "$OSASCRIPT" -e "display notification \"$msg\" with title \"check-docker-mem.sh\"" >/dev/null 2>&1 &
}

# Cooldown-aware alert: only notify once per ALERT_COOLDOWN while the condition
# persists. The cooldown state is cleared on a healthy run so a new breach
# re-alerts immediately.
alert() {
  local msg="$1" now last
  now=$(date +%s)
  last=0
  [ -f "$STATE" ] && last=$(tr -dc '0-9' <"$STATE" 2>/dev/null)
  [ -z "$last" ] && last=0
  if [ $(( now - last )) -ge "$ALERT_COOLDOWN" ]; then
    notify "$msg"
    echo "$now" >"$STATE"
    log "ALERT: $msg"
  else
    log "ALERT suppressed (cooldown ${ALERT_COOLDOWN}s): $msg"
  fi
}

# ---------- prep: log dir + rotation + single-instance lock ----------
mkdir -p "$(dirname "$LOG")"
if [ -f "$LOG" ]; then
  sz=$(stat -f%z "$LOG" 2>/dev/null || echo 0)
  [ "$sz" -gt "$MAX_LOG_BYTES" ] && mv -f "$LOG" "$LOG.1"
fi

if ! mkdir "$LOCK" 2>/dev/null; then
  # Remove a stale lock (>10 min old) left by a killed run, else skip this cycle.
  if [ -n "$(find "$LOCK" -maxdepth 0 -mmin +10 2>/dev/null)" ]; then
    rm -rf "$LOCK"; mkdir "$LOCK" 2>/dev/null || { log "could not acquire lock; skipping"; exit 0; }
  else
    log "previous run still active; skipping this cycle"; exit 0
  fi
fi
trap 'rm -rf "$LOCK"' EXIT

# ---------- ensure the docker CLI was found ----------
if [ -z "$DOCKER" ]; then
  log "docker CLI not found in any known location -- cannot check memory"
  exit 0
fi

# ---------- resolve docker endpoint (launchd has no DOCKER_HOST) ----------
if [ -S "$HOME/.orbstack/run/docker.sock" ]; then
  export DOCKER_HOST="unix://$HOME/.orbstack/run/docker.sock"
elif [ -S "/var/run/docker.sock" ]; then
  :  # default context / OrbStack symlink is fine
else
  # Socket missing = engine cleanly stopped (e.g. `hermes.sh stop` for
  # maintenance) or crashed. Log only -- no notification, to avoid nagging
  # during intentional stops. A *frozen* engine is caught below via timeouts
  # and DOES alert, since that is the actual freeze incident.
  log "docker socket not found -- OrbStack is DOWN/stopped (no alert)"
  exit 0
fi

# ---------- query VM total memory ----------
mem_total=$(run_docker info --format '{{.MemTotal}}' 2>/dev/null)
rc=$?
if [ "$rc" -eq 124 ]; then
  log "docker info timed out after ${DOCKER_TIMEOUT}s -- OrbStack likely FROZEN"
  alert "Docker is UNRESPONSIVE (frozen): 'docker info' timed out."
  exit 0
fi
case "$mem_total" in
  ''|*[!0-9]*) log "could not read VM total memory (docker unreachable, rc=$rc); no alert"
               exit 0 ;;
esac

# ---------- query per-container stats ----------
stats=$(run_docker stats --no-stream \
          --format '{{.Name}}|{{.MemUsage}}|{{.MemPerc}}|{{.CPUPerc}}' 2>/dev/null)
rc=$?
if [ "$rc" -eq 124 ]; then
  log "docker stats timed out after ${DOCKER_TIMEOUT}s -- OrbStack likely FROZEN"
  alert "Docker is UNRESPONSIVE (frozen): 'docker stats' timed out."
  exit 0
fi

# ---------- compute totals + per-container breakdown (sorted desc) ----------
# awk parses the "used" side of MemUsage (e.g. "1.23GiB / 7.65GiB"), converts to
# bytes, sums, and emits a SUMMARY line followed by a human-readable block.
report=$(printf '%s\n' "$stats" | awk -F'|' -v total="$mem_total" '
  function tobytes(s,   v,u,ul){
    v=s+0; u=s; sub(/^[0-9.]+/,"",u); gsub(/ /,"",u); ul=tolower(u)
    if      (ul ~ /^gi/) return v*1073741824
    else if (ul ~ /^mi/) return v*1048576
    else if (ul ~ /^ki/) return v*1024
    else if (ul ~ /^g/)  return v*1000000000
    else if (ul ~ /^m/)  return v*1000000
    else if (ul ~ /^k/)  return v*1000
    else                 return v
  }
  $1!="" {
    n++; nm[n]=$1; split($2,a,"/"); ub[n]=tobytes(a[1]); mp[n]=$3; cp[n]=$4; sum+=ub[n]
  }
  END{
    pct=(total>0)?(100.0*sum/total):0
    for(i=1;i<=n;i++) ord[i]=i
    for(i=1;i<=n;i++) for(j=i+1;j<=n;j++) if(ub[ord[j]]>ub[ord[i]]){t=ord[i];ord[i]=ord[j];ord[j]=t}
    top=(n>0)?nm[ord[1]]:"-"; topmb=(n>0)?ub[ord[1]]/1048576:0
    printf("SUMMARY\t%.1f\t%s\t%.0f\n", pct, top, topmb)
    printf("TOTAL containers=%d used=%.2fGiB / VM %.2fGiB (%.1f%%)\n", n, sum/1073741824, total/1073741824, pct)
    for(k=1;k<=n;k++){i=ord[k]; printf("  %-30s %9.1f MiB   mem=%-7s cpu=%s\n", nm[i], ub[i]/1048576, mp[i], cp[i])}
  }')

summary=$(printf '%s\n' "$report" | grep '^SUMMARY' | head -1)
pct=$(printf '%s' "$summary"  | cut -f2)
top=$(printf '%s' "$summary"  | cut -f3)
topmb=$(printf '%s' "$summary" | cut -f4)
[ -z "$pct" ] && pct=0

# ---------- log the breakdown ----------
{
  echo "$(ts) - docker memory check:"
  printf '%s\n' "$report" | grep -v '^SUMMARY'
} >>"$LOG"

# ---------- decide + alert ----------
over=$(awk -v p="$pct" -v t="$THRESHOLD_PCT" 'BEGIN{print (p+0>=t)?1:0}')
if [ "$over" = "1" ]; then
  alert "OrbStack VM memory at ${pct}% (>= ${THRESHOLD_PCT}%). Top: ${top} (${topmb} MiB). See $LOG"
else
  rm -f "$STATE" 2>/dev/null   # healthy: reset cooldown so next breach alerts now
  log "OK: ${pct}% of VM memory used (top: ${top} ${topmb} MiB)"
fi

# Concise line for launchd's /tmp/check-docker-mem.out
echo "$(ts) mem=${pct}% top=${top}(${topmb}MiB) threshold=${THRESHOLD_PCT}%"

# ---------- optional email (disabled; user chose notifications) ----------
# To also email alerts later without storing a password in plaintext:
#   1) create a Gmail app password, store it once:
#        security add-generic-password -a bryan.gebhardt@gmail.com \
#          -s check-docker-mem-smtp -w 'APP_PASSWORD'
#   2) in alert(), add:
#        PW=$(security find-generic-password -a bryan.gebhardt@gmail.com -s check-docker-mem-smtp -w)
#        printf 'Subject: [docker-mem] %s\n\n%s\n' "$msg" "$msg" | \
#          /usr/bin/curl -s --url 'smtps://smtp.gmail.com:465' \
#            --mail-from bryan.gebhardt@gmail.com --mail-rcpt bryan.gebhardt@gmail.com \
#            --user "bryan.gebhardt@gmail.com:$PW" -T -
