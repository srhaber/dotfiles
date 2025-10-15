#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Parse Claude Code session information
model=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')
transcript_path=$(echo "$input" | jq -r '.transcript_path')

# Parse cost information from JSON
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // "null"')
total_duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // "null"')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // "null"')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // "null"')
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')

# Format session duration from cost data
session_duration=""
if [[ "$total_duration_ms" != "null" && -n "$total_duration_ms" ]]; then
  duration_seconds=$((total_duration_ms / 1000))
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

# Format cost
cost_display=""
if [[ "$total_cost" != "null" && -n "$total_cost" ]]; then
  cost_display=$(printf "\$%.3f" "$total_cost")
fi

# Calculate message count from transcript file
message_count=""
if [[ -f "$transcript_path" ]]; then
  # Count "role": entries in the JSON (most reliable for JSONL or JSON)
  count=$(grep -c '"role"' "$transcript_path" 2>/dev/null || echo "0")

  # If we have a valid count, use it
  if [[ "$count" =~ ^[0-9]+$ && "$count" -gt 0 ]]; then
    message_count="$count"
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

  # Session duration in cyan
  if [[ -n "$session_duration" ]]; then
    claude_info="$claude_info $(printf '\033[36m')($session_duration)$(printf '\033[0m')"
  fi

  # Cost in yellow
  if [[ -n "$cost_display" ]]; then
    claude_info="$claude_info $(printf '\033[33m')$cost_display$(printf '\033[0m')"
  fi

  # Message count in blue
  if [[ -n "$message_count" ]]; then
    claude_info="$claude_info $(printf '\033[34m')($message_count msgs)$(printf '\033[0m')"
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
