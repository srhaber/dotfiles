---
description: Comprehensive review of all changes on current branch (uses convention-analyzer agent)
---

Perform a comprehensive review of all changes on the current branch.

## Phase 1: Data Gathering (Main Agent)

1. **Get branch context in parallel:**
   - `git status` → Commit state and working tree
   - `git diff main --stat` → Overview of changes
   - `git log main..HEAD --oneline` → Commits
   - `git diff main --name-only` → Changed files

2. **Show user what's being reviewed:**
   - Number of files changed
   - Types of changes (new files, modifications, deletions)
   - Scope (which modules/areas affected)
   - Note if uncommitted changes are included

## Phase 2: Deep Analysis (Custom Sub-agent)

Launch `Task(subagent_type="convention-analyzer")` with the file list from Phase 1:

```
Analyze conventions and patterns for these changed files:

[Provide the full list of changed files from git diff --name-only]

For each file, extract established conventions by comparing to similar files in the codebase.
Return findings in your standard format with file:line references.
```

The agent will receive the explicit file list and analyze each one for convention adherence.

## Phase 3: Synthesis (Main Agent)

Combine sub-agent findings with actual diff content. Review for:

**Consistency Issues:**
- Deviations from conventions identified by sub-agent
- Code style mismatches (line length, naming, formatting)
- Architecture pattern violations
- Missing type hints or incorrect types
- Async pattern issues
- Import organization problems

**Edge Cases & Concerns:**
- **Security:** Input validation, injection risks, auth checks
- **Performance:** N+1 queries, inefficient operations
- **Error handling:** Unhandled exceptions, missing edge cases
- **Race conditions:** Async safety, concurrent access
- **Data integrity:** Validation logic, constraints
- **Null handling:** Missing None checks
- **Boundaries:** Empty collections, zero values, limits

**Test Coverage:**
- New features covered?
- Edge cases tested?
- Test patterns match conventions?

## Output Format

```
## Summary
[Files changed, scope, overall assessment, uncommitted note if applicable]

## Consistency Issues
[Specific deviations with file:line, reference conventions from sub-agent]

## Edge Cases & Concerns
**Security:**
**Performance:**
**Error Handling:**
**Race Conditions:**
**Data Integrity:**
**Null Handling:**
**Boundaries:**
[Use ✓ if category has no issues]

## Test Coverage
[Assessment with specifics]

## Recommendations
1. [Prioritized action items]

## Positive Observations
[What follows conventions well]
```

**Be specific:** Always include `file.py:line` references
**Be objective:** Focus on facts over validation
**Compare to conventions:** Reference patterns sub-agent identified
