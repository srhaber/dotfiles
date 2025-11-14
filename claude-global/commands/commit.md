---
description: Analyze staged changes and commit with AI-generated message (uses commit-message-generator agent)
---

Use the Task tool to invoke the commit-message-generator subagent to analyze staged changes and generate a conventional commit message. The agent does the analysis work but returns the message to you - you handle all user interaction.

If the user provided additional context after `/commit`, pass it to the agent to incorporate into the commit message. For example:
- `/commit` → Standard commit with auto-generated message
- `/commit fix race condition in webhook processing` → Commit with context about race condition

Workflow:
1. Check git status for unstaged files (modified, deleted, or untracked)
2. If unstaged files exist, ask user if they want to stage them (use AskUserQuestion)
3. If user wants to stage files, run `git add -A` before proceeding
4. Invoke the commit-message-generator agent to analyze changes and generate commit message
5. The agent returns structured output with: proposed message, changes summary, and any notes
6. Present the proposed commit message to the user
7. Use AskUserQuestion to get approval with options:
   - "Approve and commit" → Execute the commit
   - "Request changes" → Ask for feedback and re-invoke agent with updated context
   - "Cancel" → Abort the commit
8. If approved, execute the commit using `git commit` with the generated message
9. Confirm success and display the commit hash

The agent handles analysis and message generation. You handle all user interaction and git operations.
