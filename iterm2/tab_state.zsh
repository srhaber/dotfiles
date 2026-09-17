# iTerm2 tab colour as a live session-state signal.
#
#   orange   idle — the prompt is yours
#   green    a command is running
#   crimson  blocked on you, or the last command failed
#   purple / blue   override the state colour while a command names a popcorn
#                   environment, because which account you are about to change
#                   outranks whether something is running
#
# Claude Code sessions carry the same three state colours, written by the hooks
# in claude-global/cc-tab-status.sh instead of from here. The handoff is the
# point: a tab means the same thing whether or not Claude is the thing running.
#
# Reverting at precmd rather than after the command means an interrupted or
# killed command still clears — whatever happens, the next prompt repaints.

if [[ -o interactive && "$TERM_PROGRAM" == "iTerm.app" ]]; then
  source "${0:A:h}/tab_colors.sh"

  _tab_state_poller=""
  _tab_state_ran=0

  _tab_state_preexec() {
    local cmd=$1 colour=$TAB_STATE_WORKING
    _tab_state_ran=1

    # Matching the command text rather than wrapping a command name is
    # deliberate: backend/scripts is not on PATH, so its scripts are invoked by
    # path, and this also catches a bare `aws --profile popcorn-prod ...`.
    case "$cmd" in
      *popcorn-prod*|*"-exec.sh prod"*|*"-run.sh prod"*|*"-vm.sh prod"*)
        colour=$TAB_ENV_PROD ;;
      *popcorn-dev*|*"-exec.sh dev"*|*"-run.sh dev"*|*"-vm.sh dev"*)
        colour=$TAB_ENV_DEV ;;
    esac
    tab_color_write "$TTY" "$colour"

    # claude paints this tab from its own hooks; a poller would only race them.
    case "${${(z)cmd}[1]:t}" in claude) return ;; esac

    "${0:A:h}/tab-waiting-poll.sh" "$TTY" "$colour" >/dev/null 2>&1 &!
    _tab_state_poller=$!
  }

  _tab_state_precmd() {
    local exit_status=$?

    [[ -n $_tab_state_poller ]] && kill "$_tab_state_poller" 2>/dev/null
    _tab_state_poller=""

    # ^C on an empty prompt sets a failing status without any command having
    # run. Only a command that actually executed can have failed.
    if (( _tab_state_ran && exit_status != 0 )); then
      tab_color_write "$TTY" "$TAB_STATE_ATTENTION"
    else
      tab_color_write "$TTY" "$TAB_STATE_IDLE"
    fi
    _tab_state_ran=0
  }

  preexec_functions+=(_tab_state_preexec)
  precmd_functions+=(_tab_state_precmd)
fi
