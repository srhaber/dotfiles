---
description: Monitor a PR for failed checks and review comments, fix and push until green
---

Monitor PR #$ARGUMENTS for CI failures and review comments. Loop until all checks pass and comments are addressed.

**Each iteration:**

1. Run `gh pr checks` to get CI status
2. Run `gh api` to fetch review comments and inline comments
3. If everything is green and no unaddressed comments → stop and report success
4. If checks failed → read the failed job logs via `gh run view --log-failed`, diagnose the issue, fix it, and push
5. If there are new review comments → assess each, make fixes where warranted, and push
6. After fixing a review comment, reply to it on GitHub explaining what was done, then resolve the thread via `gh api ... -X PUT` (graphQL `minimizeComment` or the resolve conversation endpoint)
7. After pushing, wait ~2 minutes for CI to start, then repeat from step 1

**Rules:**
- Only fix issues caused by this PR's changes — don't fix pre-existing failures
- Run affected tests locally before pushing to avoid unnecessary CI cycles
- Commit fixes separately from the original work with clear messages describing what was addressed
- If a review comment is a false positive or intentional design choice, note why but don't change code
- If stuck after 2 fix attempts on the same issue, stop and explain the problem instead of looping
- Poll interval: start at 60s, add 30s each cycle while checks are just queued (60→90→120→...), cap at 3 minutes. Reset to 60s after a push or state change.

**When complete, print a summary:**

```
## PR #NNN — Watch Summary

**Status:** All green / Stopped (with reason)

**Iterations:** N cycles

**Findings & Fixes:**
- {what was found} → {what was done}
- ...

**Final CI:**
- Check Name — pass/fail (duration)
- ...

**Review Comments:** N addressed, N skipped (with reasons)
```
