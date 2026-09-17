#!/bin/bash
# Watch one tty and turn its tab crimson while the foreground command looks like
# it is blocked on the keyboard. Started by the preexec hook in tab_state.zsh,
# killed by the matching precmd — so a poller exists only while a command is
# actually running, and an idle shell costs nothing.
#
# usage: tab-waiting-poll.sh <tty> <colour to restore when not waiting>
#
# Detecting "blocked on a tty read" is the hard part on macOS. The field that
# would answer it directly — the sleep channel, which reads ttyin on FreeBSD —
# is not populated on Darwin, and a process blocked on the keyboard is otherwise
# indistinguishable by state and CPU from one sleeping on a timer or a socket.
# So this uses two tiers, precise first:
#
#   1. termios. A prompt that turns echo off while staying in canonical mode is
#      reading a password or passphrase. Nothing else looks like that — a
#      full-screen app (vim, less, htop) leaves canonical mode too.
#   2. no CPU. Everything in the foreground group idle across two consecutive
#      samples. This is what catches a plain [y/N] prompt, and it is also what
#      misfires on a slow download or a `sleep`. Set TAB_WAIT_CPU_TIER=0 to
#      turn it off and keep only the precise tier.
set -u

TTY_PATH=${1:-}
BUSY_COLOUR=${2:-3fb950}
[ -n "$TTY_PATH" ] || exit 0

INTERVAL=${TAB_WAIT_POLL_INTERVAL:-3}
CPU_TIER=${TAB_WAIT_CPU_TIER:-1}
SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$SELF_DIR/tab_colors.sh"

TTY_SHORT=${TTY_PATH#/dev/}
painted=busy
prev_quiet=0

# stty prints echo/icanon as bare words and their negations with a leading '-',
# but -echo is also a prefix of -echoe, -echok and friends, so the match has to
# be anchored on both sides or every tty reads as a password prompt.
flag_off() { printf '%s' "$1" | grep -qE "(^|[^-[:alnum:]])-$2([^[:alnum:]]|\$)"; }

while :; do
  sleep "$INTERVAL"

  fg=$(ps -t "$TTY_SHORT" -o tpgid= 2>/dev/null | head -1 | tr -d ' ')
  case "$fg" in ''|*[!0-9]*) continue ;; esac
  [ "$fg" -gt 0 ] || continue

  # Claude drives this tab through its own hooks, which know far more than a
  # poller can infer. Stand down rather than fight it for the last write.
  if ps -g "$fg" -o command= 2>/dev/null | grep -qE '(^|/)claude( |$)'; then
    exit 0
  fi

  waiting=0
  termios=$(stty -f "$TTY_PATH" -a 2>/dev/null)
  if [ -n "$termios" ] && flag_off "$termios" echo && ! flag_off "$termios" icanon; then
    waiting=1
    prev_quiet=0
  elif [ "$CPU_TIER" != 0 ]; then
    quiet=$(ps -g "$fg" -o %cpu= 2>/dev/null | awk '{s+=$1} END {print (s>0.5) ? 0 : 1}')
    if [ "$quiet" = 1 ]; then
      [ "$prev_quiet" = 1 ] && waiting=1
      prev_quiet=1
    else
      prev_quiet=0
    fi
  fi

  if [ "$waiting" = 1 ] && [ "$painted" != waiting ]; then
    tab_color_write "$TTY_PATH" "$TAB_STATE_ATTENTION"
    painted=waiting
  elif [ "$waiting" = 0 ] && [ "$painted" != busy ]; then
    tab_color_write "$TTY_PATH" "$BUSY_COLOUR"
    painted=busy
  fi
done
