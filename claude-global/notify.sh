#!/bin/bash
INPUT=$(cat)
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')
MSG=$(echo "$INPUT" | jq -r '.message // "Needs your attention"')

osascript -e "display notification \"$MSG\" with title \"$TITLE\""
exit 0
