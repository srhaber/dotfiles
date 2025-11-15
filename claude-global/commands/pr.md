---
description: Create pull request for current branch (uses pr-description-generator agent)
---

Create a pull request on GitHub for the current branch.

## Usage

- `/pr` - Create a normal PR
- `/pr wip` - Create a WIP (work-in-progress) PR with "WIP: " prefix in title

## Workflow

1. **Parse command arguments:**
   - Check if `wip` flag is present after `/pr`
   - Store flag for later title modification

2. **Check branch state** (run in parallel):
   - `git branch --show-current` → Current branch name
   - `git rev-parse --abbrev-ref @{upstream} 2>&1` → Check upstream tracking
   - `git status --short --branch` → Check if ahead/behind remote
   - `git log main..HEAD --oneline` → Preview commits (assume main as base)

3. **Validate prerequisites:**
   - Must be on a branch (not detached HEAD)
   - Branch must not be main/master
   - Must have commits to push

4. **Push to remote if needed:**
   - If no upstream configured: Use AskUserQuestion to confirm push with `-u origin <branch>`
   - If local is ahead: Run `git push` to sync
   - If push fails, show error and abort

5. **Invoke pr-description-generator agent:**
   - Pass any user-provided context after `/pr` command (excluding `wip` flag)
   - Agent analyzes branch and returns PR title + body

6. **Modify title if WIP flag present:**
   - If `wip` flag was provided, prepend "WIP: " to the generated title
   - Example: "Add new feature" → "WIP: Add new feature"

7. **Present proposed PR to user:**
   - Show the generated title (with WIP prefix if applicable) and body
   - Display commits that will be included
   - Show base branch (main/master)

8. **Get user approval with AskUserQuestion:**
   - "Create PR as-is" → Execute gh pr create
   - "Edit description" → Ask for changes and re-invoke agent with feedback
   - "Cancel" → Abort

9. **Create PR:**
   - Use `gh pr create --title "<title>" --body "$(cat <<'EOF' ... EOF)"`
   - Ensure body includes Summary, Test plan, and attribution footer
   - Keep the test plan short, avoid creating too many list items
   - Display PR URL when created

10. **Handle errors:**
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
