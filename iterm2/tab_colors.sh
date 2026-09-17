# Shared iTerm2 tab-colour palette and writer.
#
# Two orthogonal signals share one tab, so they must never share a value:
#
#   state     — does this session want a human right now?
#   identity  — which environment is the running command touching?
#
# Green used to belong to identity (popcorn-prod). It now means "working", and
# prod moved to purple, so a glance at a tab never has to disambiguate the two.
#
# Every writer goes through OSC 1337 SetColors=tab and never through
# `it2 session set-color`. iTerm2 keeps those as two separate layers — the
# escape sequence is transient, set-color writes a profile override — and
# SetColors=tab=default clears only the transient one. Mix them and clearing
# reveals the profile value instead of removing the colour, leaving a tab
# stuck crimson for good.

# ---- state channel (tab background) ----
TAB_STATE_WORKING=3fb950     # a process, or Claude, is doing something
TAB_STATE_IDLE=ff8c00        # prompt is yours, nothing running
TAB_STATE_ATTENTION=d7263d   # blocked on you, or the last command failed

# ---- identity channel (tab background, outranks state for its command) ----
TAB_ENV_PROD=a371f7
TAB_ENV_DEV=1f6feb

# ---- status-bar dot, kept in lockstep with the tab ----
# iTerm2's bundled cc-status hardcodes the inverse scheme (green idle, orange
# working), which is why the hooks here call set-status themselves rather than
# deferring to it: a green dot beside a green tab has to mean the same thing.
DOT_WORKING="#$TAB_STATE_WORKING"
DOT_IDLE="#$TAB_STATE_IDLE"
DOT_ATTENTION="#$TAB_STATE_ATTENTION"

# iTerm2 ships it2 outside PATH; an iTerm2 old enough to lack it also lacks the
# session-status toolbelt, so every caller degrades to doing nothing.
tab_it2() {
  if [ -z "${IT2_BIN:-}" ]; then
    IT2_BIN=$(command -v it2 2>/dev/null || true)
    [ -z "$IT2_BIN" ] && [ -x /Applications/iTerm.app/Contents/Resources/utilities/it2 ] &&
      IT2_BIN=/Applications/iTerm.app/Contents/Resources/utilities/it2
  fi
  [ -n "$IT2_BIN" ] || return 1
  "$IT2_BIN" "$@"
}

# Resolve a session UUID to the tty it is currently attached to. Addressing a
# session by UUID needs no inherited terminal, which is what makes this callable
# from a hook, and it survives the tab being moved to another window.
tab_tty_for_uuid() {
  tab_it2 session list 2>/dev/null |
    awk -F'\t' -v s="$1" '$1==s { gsub(/\\/, "", $NF); print $NF }'
}

# $1 = tty path, $2 = hex without '#', or "default" to clear.
tab_color_write() {
  [ -n "$1" ] && [ -w "$1" ] || return 0
  printf '\033]1337;SetColors=tab=%s\a' "${2:-default}" >"$1" 2>/dev/null || return 0
}
