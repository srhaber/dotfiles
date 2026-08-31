#!/bin/bash
# Claude Code Notification hook -> macOS Notification Center.
#
# Payload on stdin: {session_id, transcript_path, cwd, hook_event_name,
#                    title, message, notification_type}
#
# Also runnable as `notify.sh --focus <iterm-session-uuid>`, which is what a
# terminal-notifier banner runs when clicked.

set -uo pipefail

LOG="${TMPDIR:-/tmp}/claude-notify.log"
log() { printf '%s\t%s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "${1//$'\n'/ }" >>"$LOG"; }

# Every AppleScript below takes its strings through `on run argv`. Payload text
# is never interpolated into script source: permission prompts quote the command
# they ask about, and an embedded " would both break the compile (banner
# silently lost) and let message text execute as AppleScript.

# Raise the exact window/tab/pane that posted the banner.
as_focus() {
  cat <<'APPLESCRIPT'
on run argv
  set target to item 1 of argv
  tell application "iTerm2"
    repeat with w in windows
      repeat with t in tabs of w
        repeat with s in sessions of t
          if (id of s) is target then
            select w
            select t
            select s
            activate
            return "focused"
          end if
        end repeat
      end repeat
    end repeat
  end tell
  return "not-found"
end run
APPLESCRIPT
}

# Where a session lives *right now*. Resolved from the UUID rather than read
# out of the wNtNpN in $ITERM_SESSION_ID - that string is fixed at shell start
# and goes stale the moment tabs are moved or closed.
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
if [[ ${1:-} == --focus ]]; then
  as_focus | osascript - "${2:-}" >/dev/null 2>&1
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

case "$KIND" in
  permission_prompt|worker_permission_prompt) LABEL="permission needed"; SOUND=Glass ;;
  agent_needs_input)                          LABEL="needs input";      SOUND=Glass ;;
  agent_completed)                            LABEL="done";             SOUND=Pop   ;;
  idle_prompt)                                LABEL="idle";             SOUND=Tink  ;;
  *)                                          LABEL="";                 SOUND=Pop   ;;
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
