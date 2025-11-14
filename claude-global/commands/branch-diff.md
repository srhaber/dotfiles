---
description: Show comprehensive diff of current branch vs main
---

Compare the current branch against main and provide a complete analysis of the **final state** of the branch.

**Commands to run:**
- `git log main..HEAD --oneline --reverse` - List all commits
- `git diff main...HEAD --name-status` - File status (A=Added, M=Modified, D=Deleted, R=Renamed)
- `git diff main...HEAD --stat` - Line change statistics
- `wc -l` on all new/modified files - Count lines

**Output format:**

1. **Commits**: List commits with hashes (chronological)

2. **Files Changed**: Group by status with line counts
   - Added (A)
   - Modified (M)
   - Deleted (D)
   - Renamed (R)

3. **Summary**: Describe **only the current/final state**
   - What exists now (not the journey to get there)
   - Architecture as it currently stands
   - Ignore intermediate decisions, refactors, or historical changes
   - Keep it high-level and brief.

**Visual-first approach (80/20 ratio):**
- Use ASCII diagrams for architecture and flows
- Use trees for file structures
- Use arrows (`→`, `↓`) for relationships
- Minimize prose - let visuals do the explaining
