---
description: Review uncommitted changes in working directory (uses convention-analyzer agent)
---

Perform a comprehensive review of uncommitted changes (both staged and unstaged).

## Arguments

- `/review-changes` → Review current staged and unstaged changes
- `/review-changes add` → Stage modified files first, then review (prompts if untracked files exist)
- `/review-changes -A` → Stage all files including untracked, then review (no prompt)
- `/review-changes --all` → Stage all files including untracked, then review (no prompt)
- `/review-changes -a` → Stage all files including untracked, then review (no prompt)
- `/review-changes all` → Stage all files including untracked, then review (no prompt)

**Auto-staging keywords:** `add`, `-A`, `--all`, `-a`, `all`

**Auto-staging logic:**
- If keyword is `-A`, `--all`, `-a`, or `all`: Run `git add -A` without prompting
- If keyword is `add`: Follow smart staging logic:
  - Check `git status --short` for file states
  - If only modified/deleted files: Run `git add -u` (tracked files only)
  - If untracked files exist: Use AskUserQuestion with options:
    - "Add all files" → Run `git add -A`
    - "Add tracked files only" → Run `git add -u`
    - "Cancel" → Abort operation
- After staging, proceed with review

## Phase 1: Data Gathering (Main Agent)

1. **Handle auto-staging if requested:**
   - If `add` argument provided, follow `/add` command logic (see Arguments section)
   - Run `git status --short` after staging to confirm

2. **Get working directory state in parallel:**
   - `git status --short` → File statuses
   - `git diff --stat` → Unstaged changes overview
   - `git diff --cached --stat` → Staged changes overview
   - `git diff --name-only` → Unstaged changed files
   - `git diff --cached --name-only` → Staged changed files

3. **Show user what's being reviewed:**
   - Number of files changed (staged vs unstaged)
   - Types of changes (new files, modifications, deletions)
   - Scope (which modules/areas affected)
   - Separate display of staged vs unstaged changes

4. **Handle edge cases:**
   - If no changes: Inform user working directory is clean
   - If only deletions: Note no code to review
   - If untracked files: Optionally include in review

## Phase 2: Deep Analysis (Custom Sub-agent)

Launch `Task(subagent_type="convention-analyzer")` with all changed files:

```
Analyze conventions and patterns for these changed files:

[Provide the combined list of staged and unstaged files]

For each file, extract established conventions by comparing to similar files in the codebase.
Return findings in your standard format with file:line references.
```

The agent will analyze each file for convention adherence.

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
- Do changes affect existing tests?
- Do new features need tests?
- Are edge cases tested?

## Output Format

```
## Summary
[Files changed, scope, overall assessment]
[Note: X files staged, Y files unstaged]

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

## Important Notes

- Reviews uncommitted changes only (not committed work)
- Includes both staged and unstaged files
- Similar depth to `/review-branch` but narrower scope
- Useful before committing to catch issues early
- Can be run multiple times as you iterate on changes
