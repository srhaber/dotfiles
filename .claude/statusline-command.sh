#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Parse Claude Code session information
model=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')
transcript_path=$(echo "$input" | jq -r '.transcript_path')

# Calculate session duration from transcript file creation time
session_duration=""
if [[ -f "$transcript_path" ]]; then
  # Get transcript file creation time (birth time on macOS)
  if birth_time=$(stat -f %B "$transcript_path" 2>/dev/null); then
    current_time=$(date +%s)
    duration_seconds=$((current_time - birth_time))

    # Format duration as HH:MM:SS or MM:SS for shorter sessions
    hours=$((duration_seconds / 3600))
    minutes=$(((duration_seconds % 3600) / 60))
    seconds=$((duration_seconds % 60))

    if [[ $hours -gt 0 ]]; then
      session_duration=$(printf "%dh%02dm%02ds" "$hours" "$minutes" "$seconds")
    elif [[ $minutes -gt 0 ]]; then
      session_duration=$(printf "%dm%02ds" "$minutes" "$seconds")
    else
      session_duration=$(printf "%ds" "$seconds")
    fi
  fi
fi

# Calculate message count from transcript file
message_count=""
if [[ -f "$transcript_path" ]]; then
  # Try multiple methods to count messages
  # Method 1: Count "role": entries in the JSON (most reliable for JSONL or JSON)
  count=$(grep -c '"role"' "$transcript_path" 2>/dev/null || echo "0")

  # If grep found nothing, try jq with different queries
  if [[ "$count" -eq 0 ]]; then
    # Try as array of messages
    count=$(jq 'if type == "array" then length else [.messages[]? | select(.role)] | length end' "$transcript_path" 2>/dev/null || echo "0")
  fi

  # If we have a valid count, use it
  if [[ "$count" =~ ^[0-9]+$ && "$count" -gt 0 ]]; then
    message_count="$count"
  fi
fi

# Note: Token usage and context information are not available in the JSON input
# provided by Claude Code to status line commands. These fields would need to be
# exposed by the Claude Code application to show cost and remaining context here.

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
  # Model in green
  claude_info="$(printf '\033[32m')$model$(printf '\033[0m')"

  # Session duration in cyan
  if [[ -n "$session_duration" ]]; then
    claude_info="$claude_info $(printf '\033[36m')($session_duration)$(printf '\033[0m')"
  fi

  # Message count in blue
  if [[ -n "$message_count" ]]; then
    claude_info="$claude_info $(printf '\033[34m')($message_count msgs)$(printf '\033[0m')"
  fi

  # Output style in yellow (if not default)
  if [[ "$output_style" != "null" && "$output_style" != "default" && -n "$output_style" ]]; then
    claude_info="$claude_info $(printf '\033[33m')[$output_style]$(printf '\033[0m')"
  fi
fi

# Print status line (two lines)
# Line 1: [timestamp TZ] directory on branch
printf "$(printf '\033[1;33m')[%s %s]$(printf '\033[0m') $(printf '\033[36m')%s$(printf '\033[0m')%s" \
  "$timestamp" "$tz" "$current" "$git_info"

# Line 2: Model (duration) [style]
if [[ -n "$claude_info" ]]; then
  printf "\n%s" "$claude_info"
fi
