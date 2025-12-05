---
description: Save an interactive summary of the current session to ~/claude-sessions/
---

You are helping document this Claude Code session for the user's personal knowledge base.

**Workflow:**

1. Use AskUserQuestion to gather:
   - Short slug (e.g., "setup-auth", "fix-bug", "api-refactor")
   - What to document: key decisions, code changes, learnings, problems solved, or all of the above

2. Analyze the conversation history directly:
   - Identify major tasks completed
   - Extract technical decisions and rationale
   - Note learnings, gotchas, insights discovered
   - Capture outcomes and what was achieved
   - Identify next steps or follow-up items

3. Generate structured markdown using the template below:
   - Use **visual-first approach**: 80% visuals for architecture/systems, liberal use for clarity
   - Include `file.py:123` line references throughout
   - Flows: `Client → API → DB`, `[State] → [State]`
   - Diagrams: `┌─────┐ ─→ ┌─────┐` for components
   - Trees: File hierarchies with `├──` and `└──`
   - Tables: Only for multi-dimensional comparisons

4. Present the generated documentation to the user

5. Use AskUserQuestion for approval:
   - "Save as-is" → Write the file
   - "Request changes" → Regenerate with user feedback
   - "Cancel" → Abort

6. If approved:
   - Ensure `~/claude-sessions/` directory exists
   - Write to `~/claude-sessions/YYYY-MM-DD-{slug}.md` (use current date from environment)
   - Confirm success and show the file path

**Documentation Template:**

```markdown
# {Session Title}

**Date:** {YYYY-MM-DD}
**Project:** {project name or "General"}
**Duration:** {approximate duration if inferable}

## Overview
{1-2 sentence summary of what was accomplished}

## Context
{Relevant background: what prompted this session, what problem was being solved}

## Key Activities
- {Major tasks completed}
- {Bulleted list}

## Technical Details
{Implementation details using visual-first approach}
{Use ASCII diagrams, flows, trees for architecture/systems}
{Use prose for debugging/decisions/concepts}

## Decisions Made
{Architectural/design/technical decisions with brief rationale}

## Learnings & Insights
{What was learned, gotchas discovered, useful patterns}

## Outcomes
{What was achieved, what works now that didn't before}

## Next Steps
{Follow-up tasks, open questions, or future work}

## References
{Links to docs, file paths with :line numbers, related PRs}
```

**Important Notes:**
- Always use current date (YYYY-MM-DD) from environment for filenames
- For architecture/system sessions: Prioritize ASCII diagrams showing component relationships
- For debugging sessions: Explain problem, investigation, root cause, solution
- For feature implementation: Show architecture, design decisions, trade-offs
- Prioritize clarity, conciseness, and future utility
