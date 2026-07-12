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
#   * Check HOST-level macOS memory (free RAM, swap, memory pressure, llama-server
#     RSS) -- the 7/11 incident showed OrbStack can be killed by host-level OOM
#     even when container memory inside the VM is fine.
#
# Design notes (learned the hard way):
#   * launchd PATH is /usr/bin:/bin:/usr/sbin:/sbin (no Homebrew) -> absolute paths.
#   * Every docker call is wrapped in `timeout`; a frozen OrbStack makes docker
#     hang forever, so a hang is treated as an alertable condition, not a block.
#   * Notifications use osascript wrapped in `timeout ... &` per the 2026-04-18
#     incident where terminal-notifier hung for 15 days and blocked a script.
#   * alert() accepts an optional state_file arg so docker/host/llama each have
#     independent cooldowns and don't suppress each other.
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
HOST_FREE_THRESHOLD_MB=150   # alert when macOS free RAM (free+speculative pages) < 150 MiB
                             # Real signal is pressure != normal (checked separately below).
                             # System routinely runs at 150-250 MiB free with OrbStack 6 GB +
                             # llama Q3_K_M; 2026-07-11 OOM crashed at ~157 MiB with pressure=warn.
LLAMA_MEM_THRESHOLD_MB=8500  # alert when llama-server RSS exceeds this (MiB)
CONTAINER_CPU_THRESHOLD=90   # alert when any container uses >= this % CPU in a single check
                             # hermes-gateway at 100%+ for 13h caused OrbStack Linux kernel RCU stall

LOG="$HOME/Library/Logs/check-docker-mem.log"
STATE="$HOME/Library/Logs/check-docker-mem.state"
HOST_STATE="$HOME/Library/Logs/check-docker-mem-host.state"
LLAMA_STATE="$HOME/Library/Logs/check-docker-mem-llama.state"
CPU_STATE="$HOME/Library/Logs/check-docker-mem-cpu.state"
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
# persists. Clear the state file on a healthy run so a new breach re-alerts
# immediately. Pass a specific state_file as $2 for independent per-category
# cooldowns (docker / host / llama); defaults to $STATE (docker).
alert() {
  local msg="$1" state_file="${2:-$STATE}" now last
  now=$(date +%s)
  last=0
  [ -f "$state_file" ] && last=$(tr -dc '0-9' <"$state_file" 2>/dev/null)
  [ -z "$last" ] && last=0
  if [ $(( now - last )) -ge "$ALERT_COOLDOWN" ]; then
    notify "$msg"
    echo "$now" >"$state_file"
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

# ---------- container CPU check ----------
# Fires when any container pegs >= CONTAINER_CPU_THRESHOLD in a single snapshot.
# hermes-gateway at 100%+ for hours caused Linux guest kernel RCU stall → OrbStack freeze.
cpu_top=$(printf '%s\n' "$stats" | awk -F'|' -v thresh="$CONTAINER_CPU_THRESHOLD" '
  $1!="" {
    cpu=$4; gsub(/%/,"",cpu); cpu+=0
    if (cpu > max) { max=cpu; maxname=$1 }
    if (cpu >= thresh && cpu > badcpu) { badcpu=cpu; badname=$1 }
  }
  END { printf "%s\t%.1f\t%s\t%.1f\n", maxname, max, badname, badcpu }
')
cpu_top_name=$(printf '%s' "$cpu_top" | cut -f1)
cpu_top_pct=$( printf '%s' "$cpu_top" | cut -f2)
cpu_bad_name=$(printf '%s' "$cpu_top" | cut -f3)
cpu_bad_pct=$( printf '%s' "$cpu_top" | cut -f4)

if [ -n "$cpu_bad_name" ]; then
  alert "Container CPU spike: ${cpu_bad_name} at ${cpu_bad_pct}% (>= ${CONTAINER_CPU_THRESHOLD}%). Guest kernel may be starved. See $LOG" "$CPU_STATE"
else
  rm -f "$CPU_STATE" 2>/dev/null
fi

# ---------- decide + alert (docker/VM) ----------
over=$(awk -v p="$pct" -v t="$THRESHOLD_PCT" 'BEGIN{print (p+0>=t)?1:0}')
if [ "$over" = "1" ]; then
  alert "OrbStack VM memory at ${pct}% (>= ${THRESHOLD_PCT}%). Top: ${top} (${topmb} MiB). See $LOG"
else
  rm -f "$STATE" 2>/dev/null   # healthy: reset cooldown so next breach alerts now
  log "OK: ${pct}% of VM memory used (top: ${top} ${topmb} MiB)"
fi

# ---------- host (macOS) memory check ----------
# Measures free RAM, swap, macOS memory pressure, and llama-server RSS.
# These are host-level signals invisible to docker stats, and were the actual
# cause of the 7/11 OrbStack freeze (llama-server + OrbStack exhausted 16 GB).
page_size=$(/usr/sbin/sysctl -n hw.pagesize 2>/dev/null || echo 16384)
vm_stat_out=$(/usr/bin/vm_stat 2>/dev/null)
free_pages=$(printf '%s\n' "$vm_stat_out" | /usr/bin/awk '/Pages free/{gsub(/\./,"",$NF); print $NF+0}')
spec_pages=$(printf '%s\n' "$vm_stat_out" | /usr/bin/awk '/Pages speculative/{gsub(/\./,"",$NF); print $NF+0}')
[ -z "$free_pages" ] && free_pages=0
[ -z "$spec_pages" ] && spec_pages=0
host_free_mb=$(( (free_pages + spec_pages) * page_size / 1048576 ))

# sysctl output: "vm.swapusage: total = N.NM  used = N.NM  free = N.NM"
swap_used_mb=$(/usr/sbin/sysctl vm.swapusage 2>/dev/null | /usr/bin/awk '{
  for(i=1;i<=NF;i++){
    if($i=="used"){ s=$(i+2); v=s+0; if(s~/G/)v=int(v*1024); printf "%d",v; break }
  }
}')
[ -z "$swap_used_mb" ] && swap_used_mb=0

# macOS memory pressure level: 1=normal 2=warn 4=critical
pressure_level=$(/usr/sbin/sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null || echo 1)
case "$pressure_level" in
  1) pressure_str="normal"   ;;
  2) pressure_str="warn"     ;;
  4) pressure_str="critical" ;;
  *) pressure_str="unknown"  ;;
esac

# Sum RSS of all llama-server processes (MiB)
llama_rss_kb=$(/bin/ps -Ao rss,comm 2>/dev/null | /usr/bin/awk '/llama-server/{sum+=$1} END{printf "%d",sum+0}')
llama_rss_mb=$(( ${llama_rss_kb:-0} / 1024 ))

log "host: free=${host_free_mb}MiB swap_used=${swap_used_mb}MiB pressure=${pressure_str} llama=${llama_rss_mb}MiB"

host_over=$(/usr/bin/awk -v f="$host_free_mb" -v t="$HOST_FREE_THRESHOLD_MB" 'BEGIN{print (f+0<t+0)?1:0}')
llama_over=$(/usr/bin/awk -v r="$llama_rss_mb" -v t="$LLAMA_MEM_THRESHOLD_MB" 'BEGIN{print (r+0>t+0)?1:0}')

if [ "$host_over" = "1" ]; then
  alert "Host RAM low: ${host_free_mb}MiB free (< ${HOST_FREE_THRESHOLD_MB}MiB). swap=${swap_used_mb}MiB pressure=${pressure_str} llama=${llama_rss_mb}MiB" "$HOST_STATE"
elif [ "$pressure_str" != "normal" ]; then
  alert "macOS memory pressure=${pressure_str}. free=${host_free_mb}MiB swap=${swap_used_mb}MiB llama=${llama_rss_mb}MiB" "$HOST_STATE"
else
  rm -f "$HOST_STATE" 2>/dev/null
fi

if [ "$llama_over" = "1" ]; then
  alert "llama-server RSS=${llama_rss_mb}MiB (>= ${LLAMA_MEM_THRESHOLD_MB}MiB). host_free=${host_free_mb}MiB" "$LLAMA_STATE"
else
  rm -f "$LLAMA_STATE" 2>/dev/null
fi

# Concise line for launchd's /tmp/check-docker-mem.out
echo "$(ts) mem=${pct}% top=${top}(${topmb}MiB) threshold=${THRESHOLD_PCT}% cpu_top=${cpu_top_name}(${cpu_top_pct}%) | host_free=${host_free_mb}MiB swap=${swap_used_mb}MiB pressure=${pressure_str} llama=${llama_rss_mb}MiB"

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
