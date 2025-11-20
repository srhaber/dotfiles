#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Parse Claude Code session information
model=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')
transcript_path=$(echo "$input" | jq -r '.transcript_path')

# Parse additional information from JSON
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')

# Calculate 5-hour session block usage across all sessions in last 96 hours
# This tracks usage across multiple conversations, not just current session
session_input_tokens=0
session_output_tokens=0
session_cache_creation_tokens=0
session_cache_read_tokens=0
session_block_end_time=0
current_session_tokens=0

# Get all JSONL files across ALL projects globally
projects_root="$HOME/.claude/projects"
if [[ -d "$projects_root" ]]; then
  # Cutoff time: 96 hours ago (4 days)
  cutoff_timestamp=$(date -u -v-96H '+%Y-%m-%dT%H:%M:%S.000Z' 2>/dev/null || date -u -d '96 hours ago' '+%Y-%m-%dT%H:%M:%S.000Z' 2>/dev/null)

  # Current time for 5-hour block calculation
  current_time=$(date -u '+%s')

  # Process all JSONL files across all projects
  # Group into 5-hour blocks and find the active block
  session_data=$(cat "$projects_root"/*/*.jsonl 2>/dev/null | \
    jq -s --arg cutoff "$cutoff_timestamp" --arg now "$current_time" '
    # Filter and deduplicate assistant messages with usage data
    [.[] | select(.type == "assistant" and .message.usage and .requestId and .timestamp)] |
    unique_by(.requestId) |

    # Filter to last 96 hours
    map(select(.timestamp >= $cutoff)) |

    # Group into 5-hour session blocks
    sort_by(.timestamp) |
    reduce .[] as $entry (
      {blocks: [], current_block: null};

      # Parse timestamp to epoch (remove milliseconds first)
      ($entry.timestamp | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601) as $ts |

      # Round to hour boundary
      ($ts - ($ts % 3600)) as $hour_start |

      if .current_block == null or
         ($ts > (.current_block.end_time)) or
         ($ts - .current_block.last_entry_time > 18000) then
        # Start new block (5 hours = 18000 seconds)
        .blocks += [.current_block] | .current_block = null |
        .current_block = {
          start_time: $hour_start,
          end_time: ($hour_start + 18000),
          last_entry_time: $ts,
          input: ($entry.message.usage.input_tokens // 0),
          output: ($entry.message.usage.output_tokens // 0),
          cache_creation: ($entry.message.usage.cache_creation_input_tokens // 0),
          cache_read: ($entry.message.usage.cache_read_input_tokens // 0)
        }
      else
        # Add to current block
        .current_block.last_entry_time = $ts |
        .current_block.input += ($entry.message.usage.input_tokens // 0) |
        .current_block.output += ($entry.message.usage.output_tokens // 0) |
        .current_block.cache_creation += ($entry.message.usage.cache_creation_input_tokens // 0) |
        .current_block.cache_read += ($entry.message.usage.cache_read_input_tokens // 0)
      end
    ) |

    # Add final block
    .blocks += [.current_block] |
    .blocks | map(select(. != null)) |

    # Find active block (where end_time > now) or use most recent
    (map(select(.end_time > ($now | tonumber))) | .[0]) //
    (sort_by(.last_entry_time) | .[-1]) //
    {input: 0, output: 0, cache_creation: 0, cache_read: 0, end_time: 0}
  ' 2>/dev/null)

  if [[ -n "$session_data" && "$session_data" != "null" ]]; then
    session_input_tokens=$(echo "$session_data" | jq -r '.input // 0')
    session_output_tokens=$(echo "$session_data" | jq -r '.output // 0')
    session_cache_creation_tokens=$(echo "$session_data" | jq -r '.cache_creation // 0')
    session_cache_read_tokens=$(echo "$session_data" | jq -r '.cache_read // 0')
    session_block_end_time=$(echo "$session_data" | jq -r '.end_time // 0')
  fi
fi

# Also calculate current session tokens for comparison
if [[ -f "$transcript_path" ]]; then
  current_session_data=$(jq -s '
    [.[] | select(.type == "assistant" and .message.usage and .requestId)] |
    unique_by(.requestId) |
    map(.message.usage) | {
      input: map(.input_tokens // 0) | add,
      output: map(.output_tokens // 0) | add,
      cache_creation: map(.cache_creation_input_tokens // 0) | add,
      cache_read: map(.cache_read_input_tokens // 0) | add
    }
  ' "$transcript_path" 2>/dev/null)

  if [[ -n "$current_session_data" && "$current_session_data" != "null" ]]; then
    current_session_tokens=$(echo "$current_session_data" | jq -r '(.input // 0) + (.output // 0) + (.cache_creation // 0) + (.cache_read // 0)')
  fi
fi

# Parse workspace information
current=$(echo "$input" | jq -r '.workspace.current_dir')
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

  # 5-hour session block token usage (simplified labels: ↑/↓ for in/out, r/w for cache)
  if [[ "$session_input_tokens" -gt 0 || "$session_output_tokens" -gt 0 ]]; then
    session_total=$((session_input_tokens + session_output_tokens + session_cache_creation_tokens + session_cache_read_tokens))

    session_input_display=$(format_tokens "$session_input_tokens")
    session_output_display=$(format_tokens "$session_output_tokens")
    session_total_display=$(format_tokens "$session_total")

    # Calculate time remaining until block reset
    time_remaining=""
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
      fi
    fi

    # Show: [5hr: total | ↑in | ↓out | ⏱time_left]
    if [[ -n "$time_remaining" ]]; then
      token_info=" $(printf '\033[36m')[5hr: ${session_total_display} | ↑${session_input_display} | ↓${session_output_display} | ⏱${time_remaining}]$(printf '\033[0m')"
    else
      token_info=" $(printf '\033[36m')[5hr: ${session_total_display} | ↑${session_input_display} | ↓${session_output_display}]$(printf '\033[0m')"
    fi

    # Add cache info: [cache: w<write> | r<read>]
    if [[ "$session_cache_read_tokens" -gt 0 || "$session_cache_creation_tokens" -gt 0 ]]; then
      cache_parts=()
      if [[ "$session_cache_creation_tokens" -gt 0 ]]; then
        cache_write_display=$(format_tokens "$session_cache_creation_tokens")
        cache_parts+=("w:${cache_write_display}")
      fi
      if [[ "$session_cache_read_tokens" -gt 0 ]]; then
        cache_read_display=$(format_tokens "$session_cache_read_tokens")
        cache_parts+=("r:${cache_read_display}")
      fi
      cache_info=$(IFS=" | "; echo "${cache_parts[*]}")
      token_info="${token_info} $(printf '\033[32m')[cache: ${cache_info}]$(printf '\033[0m')"
    fi

    claude_info="${claude_info}${token_info}"
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
