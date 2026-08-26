---
description: Generate a prompt to resume this work in a new session
argument-hint: [slug]
allowed-tools: Bash, Read, Write, Glob, Grep
---

Write a handoff a *fresh* session can act on. Assume the reader has zero context
and cannot ask you questions.

## 1. Collect ground truth FIRST (do not skip; do not write from recollection)

By the time this command runs, the conversation may already have been summarized.
Anything written from recollection is a guess — and the next session will trust it.

Resolve the repo: `git rev-parse --show-toplevel` (in `~/popcorn` the git root is a
*subdir*, so `cd` into the relevant one first — the workspace parent is not a repo).
Then run and read:

- `git branch --show-current` and `git status --short`
- `git log --oneline -8`, `git diff --stat`, `git diff --cached --stat`
- `gh pr list --head <branch> --json number,url,title,statusCheckRollup`
- Any background tasks, dev servers, or watchers still running

Every claim in the handoff must trace to this output or to command output already in
the transcript. Anything else is labelled `(unverified)`.

## 2. Write it to disk

Write to `~/claude-sessions/handoffs/YYYY-MM-DD-<slug>.md` — slug from `$ARGUMENTS`,
otherwise inferred from the work. Create the directory if needed. Then print, in this
order:

1. the file path, and the resume command: `claude "$(cat <path>)"`
2. the body itself, as plain text, so it can also be pasted directly
3. **the file path and resume command again**, as the last thing in the response

Step 3 is not redundant: the body can be long enough to push the path out of view, and
the path is what gets copied into the new session. Always end on it.

## Format

    ## Context
    {Repo, branch, worktree path. What we're doing and why. Max 3 lines.}

    ## Ground truth
    {Branch, dirty files, last commits, PR + CI state — from step 1, verbatim
    enough to be trustworthy.}

    ## Completed
    {Done AND verified, each with what proved it: "migration applied — alembic
    current shows abc123". Mark anything unproven (unverified).}

    ## Dead ends — do NOT retry
    {Approaches tried and abandoned, with the reason. This section saves the next
    session the most time. Include constraints I stated during the session:
    decisions I made, options I vetoed.}

    ## Next steps
    {Ordered and concrete. First action first.}

    ## Key files
    {file.py — symbol, one line each. NO line numbers: this file outlives the
    session and they drift the moment anything above them changes.}

    ## Environment
    {How to run the tests/app: exact commands, venv, worktree, ports. Flag any
    known-flaky step.}

    ## References
    {Plan doc, PR URLs, Linear tickets, notes or memory files written this session.}

## Rules

- **No length target.** Omit a section only when it is genuinely empty, never to hit
  a word count. A resume prompt costs a few hundred tokens; re-deriving an abandoned
  approach costs tens of thousands.
- Prose only, and only where reasoning is the point. No diagrams — this is a prompt
  for an agent, not a document for a human.
- Do not narrate or editorialize about the session. The reader is an agent picking up
  tools mid-task.
- This captures **resume state**. For durable knowledge capture — decisions,
  learnings, architecture worth reading months later — use `/save-session`.
