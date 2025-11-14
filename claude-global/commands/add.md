---
description: Stage modified and untracked files with smart prompting
---

Stage files for commit with intelligent handling of untracked files.

## Arguments

- `/add` → Stage modified files; prompt if untracked files exist
- `/add all` → Stage all files including untracked, no prompt
- `/add -A` → Stage all files including untracked, no prompt
- `/add --all` → Stage all files including untracked, no prompt

**Auto-add keywords:** If argument is `all`, `-A`, or `--all`, automatically stage everything without prompting.

## Workflow

1. Run `git status --short` to check file states

2. Categorize files:
   - **Modified (M):** Changed tracked files
   - **Deleted (D):** Removed tracked files
   - **Untracked (??):** New files not yet tracked

3. Check for auto-add keyword (`all`, `-A`, `--all`):
   - **If present:** Run `git add -A` without prompting
   - **If not present:** Continue to conditional logic

4. If no auto-add keyword:
   - **Modified/deleted only:** Run `git add -u` (stages tracked files only)
   - **Untracked files exist:** Use AskUserQuestion with options:
     - "Add all files" → Run `git add -A` (includes untracked)
     - "Add tracked files only" → Run `git add -u` (excludes untracked)
     - "Cancel" → Abort operation

5. Run `git status --short` after staging to show result

6. Display summary:
   - Number of files staged
   - File types staged (modified, deleted, new)
   - Note if untracked files were excluded

## Examples

```bash
# Scenario 1: Only modified files
/add
# → Stages all modified files, no prompt

# Scenario 2: Modified + untracked files
/add
# → Prompts: Add all or tracked only?

# Scenario 3: Force add everything
/add all
# → Stages all files including untracked, no prompt

# Scenario 4: Modified + untracked, but force all
/add -A
# → Stages all files including untracked, no prompt
```

## Important Notes

- **Tracked files only:** `git add -u` stages modifications/deletions but ignores untracked
- **All files:** `git add -A` stages everything including untracked
- Prompting helps avoid accidentally committing untracked files
- Use `all`/`-A`/`--all` when you're certain you want everything staged
