#!/bin/bash
# Claude Code hook -> iTerm2 tab colour and status-bar dot.
#
# Replaces iTerm2's bundled cc-status shim rather than wrapping it. The shim
# hardcodes its own palette — green idle, orange working, blue waiting — with no
# way to configure it, which is the inverse of the scheme every other tab on
# this machine uses. A green dot beside a green tab has to mean the same thing,
# so this writes both.
#
# Two mappings also differ from the shim's, deliberately:
#
#   SubagentStop  the shim reports idle. A subagent finishing says nothing about
#                 the session — the main loop is usually still working — and
#                 because hooks in separate matcher groups are not serialized,
#                 it would race PostToolUse and win often enough to matter. This
#                 writes nothing at all for that event.
#   StopFailure   the shim folds it into idle. A turn that failed wants a human,
#                 which is the same thing a failed shell command means, so it
#                 gets the same crimson.
#
# Lives in dotfiles; setup.sh symlinks it to ~/.claude/cc-tab-status.sh, which
# is the path the hooks in settings.json name.

set -uo pipefail

DOTFILES_DIR=$(cd "$(dirname "$(readlink "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}")")/.." && pwd)
. "$DOTFILES_DIR/iterm2/tab_colors.sh"

INPUT=$(cat)
field() { printf '%s' "$INPUT" | jq -r "$1 // \"\"" 2>/dev/null; }

EVENT=$(field .hook_event_name)
[ -n "$EVENT" ] || exit 0

case "$EVENT" in
  UserPromptSubmit|PreToolUse|PostToolUse)
    STATUS=working; TAB=$TAB_STATE_WORKING; DOT=$DOT_WORKING ;;
  PermissionRequest)
    STATUS=waiting; TAB=$TAB_STATE_ATTENTION; DOT=$DOT_ATTENTION ;;
  StopFailure)
    STATUS=idle;    TAB=$TAB_STATE_ATTENTION; DOT=$DOT_ATTENTION ;;
  SessionStart|Stop|SessionEnd)
    STATUS=idle;    TAB=$TAB_STATE_IDLE; DOT=$DOT_IDLE ;;
  *)
    exit 0 ;;
esac

# The toolbelt row says a pane wants attention; the detail says why, which is
# what decides whether to switch tabs now or finish the thought first.
case "$EVENT" in
  Stop)              DETAIL=$(field .last_assistant_message) ;;
  PermissionRequest) DETAIL="Allow $(field .tool_name)?" ;;
  *)                 DETAIL="" ;;
esac
DETAIL=${DETAIL//$'\n'/ }
# One line in a narrow toolbelt, so it gets cut here rather than mid-word there.
[ ${#DETAIL} -gt 72 ] && DETAIL="${DETAIL:0:71}…"

UUID=""
[ "${TERM_PROGRAM:-}" = iTerm.app ] && UUID=${ITERM_SESSION_ID#*:}
[ -n "$UUID" ] || exit 0

tab_it2 session set-status -s "$UUID" \
  --status "$STATUS" --detail "$DETAIL" \
  --dot-color "$DOT" --text-color "$DOT" >/dev/null 2>&1

tab_color_write "$(tab_tty_for_uuid "$UUID")" "$TAB"
exit 0
