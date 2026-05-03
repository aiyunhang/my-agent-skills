#!/usr/bin/env bash
# safe-run.sh — Helper for the run-command skill.
#
# Runs the given shell command line UNLESS it matches a hard deny
# pattern. This is a *second* line of defense; the agent itself is
# expected to apply the policy in SKILL.md first.
#
# Usage:
#   bash safe-run.sh '<command line>'
#
# Exit codes:
#   0    command ran successfully
#   non-0 (from the command itself) — propagated
#   77   blocked by deny list
#   64   bad usage

set -uo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: safe-run.sh '<command line>'" >&2
  exit 64
fi

cmd="$*"

# --- Hard deny patterns (POSIX ERE, evaluated by grep -E) ----------------
# Boundaries are written explicitly because BSD/macOS grep does not
# universally support \b.
B_L='(^|[[:space:]])'   # left boundary
B_R='([[:space:]]|$)'   # right boundary

deny_patterns=(
  # rm -r? -f? targeting /, ~, $HOME, ., ./*
  "${B_L}rm[[:space:]]+(-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]+)+(/|/\*|~|\\\$HOME|\\.|\\./\\*)${B_R}"
  # filesystem-destroying writes
  "${B_L}mkfs(\\.[a-z0-9]+)?${B_R}"
  "${B_L}dd[[:space:]]+if=/dev/(zero|random|urandom)[[:space:]]+of=/dev/"
  # raw block-device redirects
  '>[[:space:]]*/dev/(sd[a-z]|nvme[0-9]|mem|kmem)'
  # fork bomb
  ':\(\)[[:space:]]*\{[[:space:]]*:\|:&'
  # remote-pipe-to-shell (RCE pattern)
  "${B_L}(curl|wget|fetch)[[:space:]]+[^|]*\\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash|zsh|ksh|dash|python|perl|ruby|node)${B_R}"
  # chmod / chown -R 777 starting at /
  "${B_L}chmod[[:space:]]+(-R[[:space:]]+)?[0-7]*7{2,3}[[:space:]]+/"
  "${B_L}chown[[:space:]]+-R[[:space:]]+[^[:space:]]+[[:space:]]+/"
  # disabling host firewall / SELinux globally
  "${B_L}setenforce[[:space:]]+0${B_R}"
  "${B_L}ufw[[:space:]]+disable${B_R}"
  "${B_L}iptables[[:space:]]+-F${B_R}"
  # power off / reboot
  "${B_L}(shutdown|halt|poweroff|reboot|init[[:space:]]+0)${B_R}"
  # exfiltration of common secret files (read + pipe out)
  "${B_L}(cat|less|more|tail|head)[[:space:]]+[^|]*(id_rsa|id_ed25519|\\.aws/credentials|\\.kube/config|\\.netrc|\\.pgpass)[^|]*\\|"
)

for pat in "${deny_patterns[@]}"; do
  if printf '%s' "$cmd" | grep -E -q -- "$pat"; then
    {
      echo "[safe-run] BLOCKED by deny list."
      echo "[safe-run] command : ${cmd}"
      echo "[safe-run] pattern : ${pat}"
    } >&2
    exit 77
  fi
done

# --- Run with timeout ----------------------------------------------------
timeout_secs="${SAFE_RUN_TIMEOUT:-30}"

if command -v timeout >/dev/null 2>&1; then
  exec timeout --preserve-status "${timeout_secs}" bash -c -- "${cmd}"
elif command -v gtimeout >/dev/null 2>&1; then
  exec gtimeout --preserve-status "${timeout_secs}" bash -c -- "${cmd}"
else
  exec bash -c -- "${cmd}"
fi
