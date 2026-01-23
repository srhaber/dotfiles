#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Parse Claude Code session information
model=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')
transcript_path=$(echo "$input" | jq -r '.transcript_path')

# Parse additional information from JSON
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')

# Parse context window usage (current conversation)
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
current_usage=$(echo "$input" | jq -r '.context_window.current_usage // null')
context_used=0
if [[ "$current_usage" != "null" ]]; then
  context_used=$(echo "$current_usage" | jq -r '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
fi
context_remaining=$((context_window_size - context_used))

# Get 5-hour block end time from JSONL files
projects_root="$HOME/.claude/projects"
session_block_end_time=0

if [[ -d "$projects_root" ]]; then
  current_time=$(date -u '+%s')

  # Find the active 5-hour block end time
  session_block_end_time=$(cat "$projects_root"/*/*.jsonl 2>/dev/null | \
    jq -s --arg now "$current_time" '
    [.[] | select(.type == "assistant" and .message.usage and .requestId and .timestamp)] |
    unique_by(.requestId) |
    map(.timestamp | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601) |
    sort |
    reduce .[] as $ts (
      {blocks: [], current_block: null};
      ($ts - ($ts % 3600)) as $hour_start |
      if .current_block == null or
         ($ts > .current_block.end_time) or
         ($ts - .current_block.last > 18000) then
        .blocks += [.current_block] |
        .current_block = {end_time: ($hour_start + 18000), last: $ts}
      else
        .current_block.last = $ts
      end
    ) |
    .blocks += [.current_block] |
    (.blocks | map(select(. != null)) |
      (map(select(.end_time > ($now | tonumber))) | .[0].end_time) //
      (sort_by(.last) | .[-1].end_time) // 0
    )
  ' 2>/dev/null)
fi

# Parse workspace information
current=$(echo "$input" | jq -r '.workspace.current_dir' | sed "s|^$HOME|~|")
project=$(echo "$input" | jq -r '.workspace.project_dir')

# Get timestamp
timestamp=$(date '+%a %F %T')
tz=$(date '+%Z')

# Get git branch information
git_info=""
if git -C "$current" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$current" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || \
           git -C "$current" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    git_info=" on $(printf '\033[35m')$branch$(printf '\033[0m')"
  fi
fi

# Build Claude Code session info (line 2)
claude_info=""
if [[ "$model" != "null" && -n "$model" ]]; then
  # Simplify model name (extract just the model type)
  model_short=$(echo "$model" | sed -E 's/.*claude-([^-]+)-([0-9]+-[0-9]+).*/\1 \2/' | sed 's/-/./')

  # Model in green
  claude_info="$(printf '\033[32m')$model_short$(printf '\033[0m')"

  # Format with k/M suffix for readability
  format_tokens() {
    local num=$1
    if [[ $num -ge 1000000 ]]; then
      printf "%.1fM" $(echo "scale=1; $num / 1000000" | bc)
    elif [[ $num -ge 1000 ]]; then
      printf "%.1fk" $(echo "scale=1; $num / 1000" | bc)
    else
      printf "%d" "$num"
    fi
  }

  # Context remaining (current conversation)
  if [[ "$context_used" -gt 0 ]]; then
    context_pct=$((context_used * 100 / context_window_size))
    remaining_display=$(format_tokens "$context_remaining")
    # Color: green <50%, yellow 50-75%, red >75%
    if [[ $context_pct -ge 75 ]]; then
      ctx_color="\033[1;31m"  # red
    elif [[ $context_pct -ge 50 ]]; then
      ctx_color="\033[33m"    # yellow
    else
      ctx_color="\033[32m"    # green
    fi
    claude_info="${claude_info} $(printf "$ctx_color")[ctx: ${remaining_display} left]$(printf '\033[0m')"
  fi

  # 5-hour block time remaining
  if [[ "$session_block_end_time" -gt 0 ]]; then
    current_epoch=$(date -u '+%s')
    seconds_remaining=$((session_block_end_time - current_epoch))

    if [[ $seconds_remaining -gt 0 ]]; then
      hours=$((seconds_remaining / 3600))
      minutes=$(((seconds_remaining % 3600) / 60))

      if [[ $hours -gt 0 ]]; then
        time_remaining=$(printf "%dh%dm" "$hours" "$minutes")
      else
        time_remaining=$(printf "%dm" "$minutes")
      fi

      claude_info="${claude_info} $(printf '\033[36m')[5hr: ⏱${time_remaining}]$(printf '\033[0m')"
    fi
  fi

  # 200k token warning in red
  if [[ "$exceeds_200k" == "true" ]]; then
    claude_info="$claude_info $(printf '\033[1;31m')[>200K]$(printf '\033[0m')"
  fi

  # Output style in yellow (if not default)
  if [[ "$output_style" != "null" && "$output_style" != "default" && -n "$output_style" ]]; then
    claude_info="$claude_info $(printf '\033[35m')[$output_style]$(printf '\033[0m')"
  fi
fi

# Print status line (two lines)
# Line 1: timestamp TZ directory on branch
printf "$(printf '\033[33m')%s %s$(printf '\033[0m') $(printf '\033[36m')%s$(printf '\033[0m')%s" \
  "$timestamp" "$tz" "$current" "$git_info"

# Line 2: Model (duration) [style]
if [[ -n "$claude_info" ]]; then
  printf "\n%s" "$claude_info"
fi
