---
description: Analyze staged changes and commit with AI-generated message (uses commit-message-generator agent)
---

Use the Task tool to invoke the commit-message-generator subagent to analyze staged changes and generate a conventional commit message. The agent does the analysis work but returns the message to you - you handle all user interaction.

## Arguments

The command supports auto-staging and custom context:
- `/commit` → Standard commit with auto-generated message (prompts if unstaged files exist)
- `/commit add` → Auto-stage all files, then commit
- `/commit -A` → Auto-stage all files, then commit
- `/commit fix race condition in webhook processing` → Commit with custom context (prompts if unstaged files exist)
- `/commit add fix race condition` → Auto-stage and commit with custom context

**Auto-staging keywords:** If the first argument is `add`, `-A`, `--all`, or `-a`, automatically run `git add -A` without prompting.

**Custom context:** Any other arguments are passed to the agent as context for the commit message.

Workflow:
1. Check git status for unstaged files (modified, deleted, or untracked)
2. Check if first argument is an auto-staging keyword (`add`, `-A`, `--all`, `-a`)
3. If auto-staging keyword provided: run `git add -A` without prompting
4. If unstaged files exist and no auto-staging keyword: ask user if they want to stage them (use AskUserQuestion)
5. If user wants to stage files, run `git add -A` before proceeding
6. Extract any remaining arguments (after auto-staging keyword if present) as custom context
7. Invoke the commit-message-generator agent to analyze changes and generate commit message (pass custom context if provided)
8. The agent returns structured output with: proposed message, changes summary, and any notes
9. Present the proposed commit message to the user
10. Use AskUserQuestion to get approval with options:
    - "Approve and commit" → Execute the commit
    - "Request changes" → Ask for feedback and re-invoke agent with updated context
    - "Cancel" → Abort the commit
11. If approved, execute the commit using `git commit` with the generated message
12. Confirm success and display the commit hash

The agent handles analysis and message generation. You handle all user interaction and git operations.
