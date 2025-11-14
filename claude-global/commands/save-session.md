---
description: Save an interactive summary of the current session to ~/claude-sessions/ (uses session-documenter agent)
---

You are helping the user document this Claude Code session for their personal knowledge base.

**Workflow:**

1. Use AskUserQuestion to gather:
   - A short label/slug for this session (e.g., "setup-knowledge-base", "fix-auth-bug", "api-refactoring")
   - What they'd like you to document: key decisions, code changes, learnings, problems solved, or all of the above

2. Invoke the `session-documenter` agent with Task tool:
   - Pass the slug and documentation preferences as context
   - The agent will analyze the conversation and return structured markdown

3. Review the agent's output and present it to the user

4. Use AskUserQuestion to get approval:
   - "Save as-is" → Write the file
   - "Request changes" → Ask for feedback and re-invoke agent with updated context
   - "Cancel" → Abort

5. If approved, write to `~/claude-sessions/YYYY-MM-DD-{slug}.md`

6. Confirm success and show the file path

The agent handles all analysis and content generation. You handle user interaction and file writing.

**Important Notes:**
- Always use current date (YYYY-MM-DD) from environment for filenames
- Ensure `~/claude-sessions/` directory exists before writing
- The agent applies visual-first approach (80/20 for architecture, liberal use otherwise)
- Include file:line references throughout documentation
