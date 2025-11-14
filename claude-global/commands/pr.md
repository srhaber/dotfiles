---
description: Create pull request for current branch (uses pr-description-generator agent)
---

Create a pull request on GitHub for the current branch.

## Workflow

1. **Check branch state** (run in parallel):
   - `git branch --show-current` → Current branch name
   - `git rev-parse --abbrev-ref @{upstream} 2>&1` → Check upstream tracking
   - `git status --short --branch` → Check if ahead/behind remote
   - `git log main..HEAD --oneline` → Preview commits (assume main as base)

2. **Validate prerequisites:**
   - Must be on a branch (not detached HEAD)
   - Branch must not be main/master
   - Must have commits to push

3. **Push to remote if needed:**
   - If no upstream configured: Use AskUserQuestion to confirm push with `-u origin <branch>`
   - If local is ahead: Run `git push` to sync
   - If push fails, show error and abort

4. **Invoke pr-description-generator agent:**
   - Pass any user-provided context after `/pr` command
   - Agent analyzes branch and returns PR title + body

5. **Present proposed PR to user:**
   - Show the generated title and body
   - Display commits that will be included
   - Show base branch (main/master)

6. **Get user approval with AskUserQuestion:**
   - "Create PR as-is" → Execute gh pr create
   - "Edit description" → Ask for changes and re-invoke agent with feedback
   - "Cancel" → Abort

7. **Create PR:**
   - Use `gh pr create --title "<title>" --body "$(cat <<'EOF' ... EOF)"`
   - Ensure body includes Summary, Test plan, and attribution footer
   - Display PR URL when created

8. **Handle errors:**
   - If `gh` not installed: Prompt to install GitHub CLI
   - If not authenticated: Prompt to run `gh auth login`
   - If PR already exists: Show existing PR URL
   - For other errors: Display git/gh error messages

## Important Notes

- The agent generates the description; you handle git operations and user interaction
- Always include the attribution footer: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`
- Default base branch is `main`, fallback to `master` if main doesn't exist
- Check `gh` is installed before attempting PR creation
- Never create PRs from main/master branch - warn the user

## PR Body Format

The agent returns structured content. Format it as:

```markdown
## Summary
- High-level change 1
- High-level change 2

## Test plan
- [ ] Testing step 1
- [ ] Testing step 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Edge Cases

- **No upstream:** Ask to push with `-u` flag first
- **Uncommitted changes:** Warn but allow (they won't be in PR)
- **No base branch divergence:** Warn that PR would be empty
- **Behind remote:** Suggest pulling first
- **Not a git repo:** Show clear error message
