---
description: Save an interactive summary of the current session to ~/claude-sessions/
---

You are helping the user document this Claude Code session for their personal knowledge base.

**Your task:**

1. First, use AskUserQuestion to gather:
   - A short label/slug for this session (e.g., "setup-knowledge-base", "fix-auth-bug", "api-refactoring")
   - What they'd like you to document: key decisions, code changes, learnings, problems solved, or all of the above

2. Create a session document at `~/claude-sessions/YYYY-MM-DD-{slug}.md` with this structure:

```markdown
# {Session Title}

**Date:** {YYYY-MM-DD}
**Project:** {current working directory or "General"}
**Duration:** {approximate session length if inferable}

## Overview
{1-2 sentence summary of what was accomplished}

## Context
{Relevant background: what prompted this session, what problem was being solved}

## Key Activities
{Bulleted list of major tasks completed:}
- Task 1
- Task 2

## Technical Details
{Important implementation details, commands run, files modified, etc.}

**Use visual representations whenever possible:**
- ASCII flow diagrams for system architecture, event flows, and state machines
- Tables for comparing options, listing handlers/triggers, or showing configurations
- Code structure diagrams showing file relationships
- Sequence diagrams for interactions between components

## Decisions Made
{Any architectural, design, or technical decisions with brief rationale}

## Learnings & Insights
{What was learned during this session, gotchas discovered, useful patterns}

## Outcomes
{What was achieved, what works now that didn't before}

## Next Steps
{Any follow-up tasks, open questions, or future work identified}

## References
{Links to docs, file paths with line numbers, related PRs, etc.}
```

3. Analyze the current conversation to fill in each section based on what we discussed and accomplished.

4. Write the file and confirm to the user where it was saved.

**Important:**
- CRITICAL: Check the "Today's date" field in your <env> context and use that exact date (YYYY-MM-DD format). Do NOT use any hardcoded date.
- Keep it concise but informative (aim for 1-2 pages)
- Include specific file paths and line numbers where relevant using the format `file:line`
- If there were no activities in a section, write "N/A" instead of leaving it empty
- Focus on information that would be useful when returning to this topic later

**Visual Representations - Adapt to Session Type:**

**For architecture/system documentation:** Target 80% visuals, 20% prose
**For other sessions:** Use visuals liberally when they clarify concepts

Session types that benefit most from visuals:
- Architecture reviews, handler/trigger mappings, database patterns, system flows
- Configuration comparisons, event routing, file structures

Session types that may need more prose:
- Debugging investigations, decision discussions, conceptual explorations
- Code review discussions with nuanced feedback

**Guideline:** Use the format that makes information most accessible. Prefer diagrams and flows over tables when possible.

Create ASCII visuals to make complex information easier to understand:

1. **Flow Diagrams** - For processes, event flows, or state transitions:
   ```
   Client → API → Database
     ↓
   Response
   ```

2. **Architecture Diagrams** - For system components and their interactions:
   ```
   ┌─────────┐     ┌─────────┐
   │ Service │────▶│  Queue  │
   └─────────┘     └─────────┘
   ```

3. **State Machines** - For lifecycle or status changes:
   ```
   [Created] → [Processing] → [Complete]
                    ↓
                [Failed]
   ```

4. **Tree Structures** - For file hierarchies or decision trees:
   ```
   src/
   ├── handlers/
   │   ├── connect.py
   │   └── default.py
   └── utils/
   ```

5. **Tables** - Use selectively for comparing structured data across multiple dimensions:
   | Handler | Trigger | Database | Output |
   |---------|---------|----------|--------|
   | foo.py  | HTTP    | Read     | JSON   |

**When to Use Prose:**
- Decision rationale ("Why did we choose X over Y?")
- Edge cases & gotchas (explanations of HOW to avoid issues)
- Context & narrative (what prompted this work)
- Insights & learnings (synthesizing observations)

**Always prioritize visuals over prose when explaining:**
- System architecture, event flows, or component relationships
- Handler/trigger mappings
- Database access patterns
- Configuration options
- File structures
- State transitions
- Comparisons of approaches
