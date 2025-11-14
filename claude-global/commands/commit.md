---
description: Commit staged changes with auto-generated conventional commit message
---

Use the Task tool to invoke the git-committer subagent to analyze staged changes and create a commit with an automatically generated conventional commit message.

If the user provided additional context after `/commit`, pass it to the agent to incorporate into the commit message. For example:
- `/commit` → Standard commit with auto-generated message
- `/commit fix race condition in webhook processing` → Commit with context about race condition

The git-committer agent will:
1. Check for unstaged files and ask if they should be staged
2. Analyze all staged changes
3. Generate a conventional commit message
4. Create the commit
5. Display the commit hash

Always invoke the agent even if no context is provided - the agent handles all commit logic.
