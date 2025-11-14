---
description: Push current branch to remote repository
---

Push the current branch to the remote repository, handling upstream branch configuration automatically.

Workflow:
1. Check current branch name with `git branch --show-current`
2. Check if the branch has an upstream configured with `git rev-parse --abbrev-ref @{upstream}`
3. If no upstream exists:
   - Use AskUserQuestion to confirm pushing with `--set-upstream`
   - If approved, run `git push -u origin <branch-name>`
   - If cancelled, abort the operation
4. If upstream exists:
   - Check if local branch is ahead/behind with `git status --short --branch`
   - Run `git push` to push to the configured upstream
5. Display the result including:
   - Branch name
   - Remote name and branch
   - Number of commits pushed
   - Any relevant git output

Error handling:
- If push is rejected (non-fast-forward), inform user and suggest options: pull first, or force push (with warning)
- If authentication fails, display the error and suggest checking credentials
- For any other errors, display the git error message clearly

Safety:
- NEVER use `--force` or `--force-with-lease` unless explicitly requested by user
- Warn user if they're pushing to main/master branch
- Show summary of commits being pushed before executing
