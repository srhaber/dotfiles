#!/bin/bash
# Claude Code Notification hook -> macOS Notification Center + iTerm2 status.
#
# Payload on stdin: {session_id, transcript_path, cwd, hook_event_name,
#                    title, message, notification_type}
#
# Also runnable as `notify.sh --focus <iterm-session-uuid>`, which is what a
# terminal-notifier banner runs when clicked.
#
# Lives in dotfiles; setup.sh symlinks it to ~/.claude/notify.sh, which is the
# path the Notification hook in settings.json names.

set -uo pipefail

LOG="${TMPDIR:-/tmp}/claude-notify.log"
log() { printf '%s\t%s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "${1//$'\n'/ }" >>"$LOG"; }

# ------------------------------------------------------------------- iTerm2 CLI
# The palette, the it2 lookup and the tab-colour writer are shared with the
# shell prompt hooks and the Claude Code status hook, so all three agree on what
# a colour means and on which iTerm2 layer it is written to.
DOTFILES_DIR=$(cd "$(dirname "$(readlink "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}")")/.." && pwd)
. "$DOTFILES_DIR/iterm2/tab_colors.sh"

it2() {
  tab_it2 "$@" >/dev/null 2>&1 || log "it2 $* failed"
}

# ------------------------------------------------------------- iTerm2 tab colour
# Tab colour carries session state, the same three colours the shell prompt
# hooks paint. The escape goes to the session's own tty, looked up from the
# UUID rather than to /dev/tty: addressing by UUID needs no inherited terminal
# at all, which is what makes it safe to call from a hook, and it survives a tab
# being moved.
tab_color() {
  local tty
  [[ -n $UUID ]] || return 0
  tty=$(tab_tty_for_uuid "$UUID")
  [[ -n $tty ]] || { log "tab colour: no tty for $UUID"; return 0; }
  tab_color_write "$tty" "$1"
}

# Each AppleScript below takes its strings through `on run argv`. Payload text
# is never interpolated into script source: permission prompts quote the command
# they ask about, and an embedded " would both break the compile (banner
# silently lost) and let message text execute as AppleScript.

# Where a session lives *right now*. Resolved from the UUID rather than read
# out of the wNtNpN in $ITERM_SESSION_ID - that string is fixed at shell start
# and goes stale the moment tabs are moved or closed. Still AppleScript because
# `it2 session list` knows ids and names but not window/tab/pane coordinates.
as_locate() {
  cat <<'APPLESCRIPT'
on run argv
  set target to item 1 of argv
  tell application "iTerm2"
    repeat with w from 1 to count of windows
      tell window w
        repeat with t from 1 to count of tabs
          tell tab t
            repeat with s from 1 to count of sessions
              if (id of session s) is target then
                if (count of sessions) > 1 then
                  return "win " & w & " · tab " & t & " · pane " & s
                else
                  return "win " & w & " · tab " & t
                end if
              end if
            end repeat
          end tell
        end repeat
      end tell
    end repeat
  end tell
  return ""
end run
APPLESCRIPT
}

# Fallback banner. The `tell application "iTerm2"` wrapper matters: an
# unwrapped `display notification` is owned by Script Editor, and Script Editor
# is what launches when you click the banner.
as_notify() {
  cat <<'APPLESCRIPT'
on run argv
  set {t, subt, m, snd} to argv
  tell application "iTerm2"
    if subt is "" then
      display notification m with title t sound name snd
    else
      display notification m with title t subtitle subt sound name snd
    end if
  end tell
end run
APPLESCRIPT
}

# ---------------------------------------------------------------- focus mode
# `session focus` selects the tab inside iTerm2; `app activate` is what brings
# the window forward when another app holds focus. Both are needed - selecting
# a tab in a background app changes nothing the user can see.
if [[ ${1:-} == --focus ]]; then
  it2 session focus "${2:-}"
  it2 app activate
  exit 0
fi

# --------------------------------------------------------------- parse input
INPUT=$(cat)

# One jq pass, NUL-delimited so a message containing newlines survives intact.
if command -v jq >/dev/null 2>&1; then
  {
    IFS= read -r -d '' MSG
    IFS= read -r -d '' KIND
    IFS= read -r -d '' CWD
  } < <(printf '%s' "$INPUT" | jq -j '
      [ .message           // "Needs your attention",
        .notification_type // "",
        .cwd               // ""
      ] | .[] | . + "\u0000"' 2>/dev/null)
fi

# jq missing, or payload unparseable - still fire something.
MSG=${MSG:-Needs your attention}
KIND=${KIND:-}
CWD=${CWD:-$PWD}

# ------------------------------------------------------------ build identity
# The banner leads with the project and the live tab coordinates, so the right
# window is identifiable without clicking anything.
PROJECT=${CWD##*/}
[[ -z $PROJECT ]] && PROJECT="Claude Code"

# LABEL and SOUND drive the banner; STATUS and DOT drive the toolbelt row.
# `waiting` is the fallback because an unrecognized notification_type is far
# likelier to be a new flavor of "Claude wants something" than one of "done".
case "$KIND" in
  permission_prompt|worker_permission_prompt)
    LABEL="permission needed"; SOUND=Glass; STATUS=waiting; DOT=$DOT_ATTENTION; TAB=$TAB_STATE_ATTENTION ;;
  agent_needs_input)
    LABEL="needs input";       SOUND=Glass; STATUS=waiting; DOT=$DOT_ATTENTION; TAB=$TAB_STATE_ATTENTION ;;
  agent_completed)
    LABEL="done";              SOUND=Pop;   STATUS=idle;    DOT=$DOT_IDLE;     TAB=$TAB_STATE_IDLE ;;
  idle_prompt)
    LABEL="idle";              SOUND=Tink;  STATUS=idle;    DOT=$DOT_IDLE;     TAB=$TAB_STATE_IDLE ;;
  *)
    LABEL="";                  SOUND=Pop;   STATUS=waiting; DOT=$DOT_ATTENTION; TAB=$TAB_STATE_ATTENTION ;;
esac

UUID=""
WHERE=""
if [[ ${TERM_PROGRAM:-} == iTerm.app && -n ${ITERM_SESSION_ID:-} ]]; then
  UUID=${ITERM_SESSION_ID#*:}
  WHERE=$(as_locate | osascript - "$UUID" 2>/dev/null)
fi

# "win 1 · tab 2 — permission needed", with either half optional.
if   [[ -n $WHERE && -n $LABEL ]]; then SUBTITLE="$WHERE — $LABEL"
elif [[ -n $WHERE ]];              then SUBTITLE="$WHERE"
else                                    SUBTITLE="$LABEL"
fi

# ------------------------------------------------------- iTerm2 status detail
# The bundled cc-status shim reports working/waiting/idle but never sees the
# message text, so its toolbelt row says a pane wants attention without saying
# why - and why is what decides whether to switch tabs now or finish the
# thought first.
#
# Last write wins, and hooks in separate matcher groups are not serialized, so
# cc-status is deliberately unregistered from Notification in settings.json to
# leave this the only writer for the event. No other hook fires while Claude
# waits on the user, so the detail survives the whole wait.
if [[ -n $UUID ]]; then
  DETAIL=${MSG//$'\n'/ }
  # The row is one line in a narrow toolbelt, and a permission prompt quotes the
  # whole command it asks about - so it gets cut here rather than mid-word there.
  [[ ${#DETAIL} -gt 72 ]] && DETAIL="${DETAIL:0:71}…"
  it2 session set-status -s "$UUID" \
    --status "$STATUS" --detail "$DETAIL" --dot-color "$DOT" --text-color "$DOT"
  tab_color "$TAB"
fi

# ---------------------------------------------------------------- deliver it
SELF=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")

if command -v terminal-notifier >/dev/null 2>&1; then
  # Posts under its own bundle id, so clicking never reaches Script Editor,
  # and -execute makes the click land on the tab that asked.
  ARGS=(-title "$PROJECT" -message "$MSG" -sound "$SOUND")
  [[ -n $SUBTITLE ]] && ARGS+=(-subtitle "$SUBTITLE")
  # One slot per session: a new prompt replaces the stale one instead of stacking.
  [[ -n $UUID ]] && ARGS+=(-group "claude-$UUID" -execute "'$SELF' --focus '$UUID'")
  ERR=$(terminal-notifier "${ARGS[@]}" 2>&1) || log "terminal-notifier: $ERR"
else
  ERR=$(as_notify | osascript - "$PROJECT" "$SUBTITLE" "$MSG" "$SOUND" 2>&1) \
    || log "osascript: $ERR"
fi

exit 0
