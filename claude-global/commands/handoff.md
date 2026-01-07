---
description: Generate a prompt to resume this work in a new session
---

Generate a concise handoff prompt I can paste into a new Claude Code session to resume this work.

**Format:**

```
## Context
{Project/repo and what we're working on - 1-2 sentences}

## Completed
{Bulleted list of what was done this session}

## Current State
{Where things stand now - files modified, tests passing, etc.}

## Remaining (optional)
{Any known next steps or open items}

## Key Files
{Most relevant files with brief description}
```

**Guidelines:**
- Keep it under 20 lines total
- Focus on actionable context, not history
- Include file paths that would help orientation
- Skip sections if not applicable
- Output as plain text (no code fence) so I can copy directly
