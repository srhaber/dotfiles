# Personal Claude Code Preferences

## Documentation Style: Visual-First

Target **80% visuals, 20% prose** for architecture/systems. Use visuals liberally when they clarify concepts.

**Use visuals for:** Architecture, flows, mappings, schemas, event routing, state transitions, file structures
**Use prose for:** Debugging investigations, decision rationale, conceptual discussions, edge cases, insights

### Visual Types

**Flows:** `Client → API → DB`, `[State] → [State]`
**Diagrams:** `┌─────┐ ─→ ┌─────┐` for components
**Trees:** File hierarchies with `├──` and `└──`
**Tables:** Only for multi-dimensional comparisons, code locations

**Symbols:** `→` flow, `↓` next step, `├──▶` branch. Always include `file.py:123` line numbers.

## Communication Style

Concise, direct, bullet points over paragraphs. Prioritize technical accuracy over validation. Challenge assumptions when appropriate—objective guidance beats false agreement.

## GitHub URL Handling

**Never fetch GitHub URLs directly.** Always parse relevant information from the URL and use `gh api` instead.

**Example:** `https://github.com/owner/repo/issues/123` → `gh api repos/owner/repo/issues/123`

**Why:** `gh api` respects authentication, avoids rate limits, and provides structured JSON responses.

## Asking Questions

**Always clarify before executing when:**
- Multiple valid approaches exist
- Requirements are ambiguous
- Irreversible operations (force push, data deletion)
- Security/permission implications

**Make reasonable assumptions for:**
- Standard conventions (variable naming, file structure)
- Common patterns in the codebase
- Low-risk decisions (formatting preferences)

## Response Length

**Concise (1-3 lines):** Confirmations, simple answers, clarifying questions
**Medium (5-10 lines):** Instructions, explanations, single-file changes
**Detailed (10+ lines):** Architecture diagrams, multi-file changes, complex debugging

Default to shorter responses. Expand only when visuals or detail add value.

## Token Efficiency: Instructions vs. Execution

**Principle:** Provide instructions instead of doing work when manual execution is faster/cheaper. Optimize for user's token quota and context limits.

### Always Provide Instructions (Don't Execute)

**Git operations:**
- Cherry-picking: `git cherry-pick <hash>`
- Resetting branches: `git reset --hard <ref>`
- Rebasing: `git rebase -i <ref>`
- Single-file reverts from history

**Simple edits:**
- Changes visible in recent `git diff`
- Single-line modifications
- Edits to code user just wrote/reviewed

**Known commands:**
- Running existing scripts: `./script.sh`
- Package management: `npm install`, `brew install`
- Standard workflows user has done before
- File operations: `mv`, `cp`, `rm`

**Repetitive tasks:**
- Operations user will do multiple times
- Workflows worth documenting
- Pattern-based changes user can apply

### Provide Both Options (Let User Decide)

- Multi-file refactors with clear patterns
- Moderate complexity (3-5 file edits)
- Tasks requiring 5-10 commands
- Migrations/upgrades with known steps

### Execute Directly (Use LLM)

- Unfamiliar codebases requiring exploration
- Complex cross-file logic changes
- Uncertain scope (need search/analysis first)
- Debugging unknown issues
- Writing new substantial code
- Pattern matching with unclear boundaries

### Trigger Phrases → Provide Instructions

**Definite instruction mode:**
- "help me..."
- "how do I..."
- "what's the command to..."
- "show me how to..."
- "walk me through..."
- "what should I run..."

**Probable instruction mode (assess first):**
- "revert..." / "undo..."
- "fix..." (if simple/obvious)
- "change X to Y" (if single location)
- "run..." / "execute..."

**Execute directly:**
- "implement..."
- "add feature..."
- "refactor..."
- "find all..." / "search for..."
- "debug why..."

### Instruction Format

When providing instructions instead of executing:

⚡ **More efficient to do manually**

**Token cost:** Manual ~0 tokens vs LLM ~30-40K tokens
**Time:** ~1-2 minutes

**Procedure:**
```bash
# Step 1: Description
command here

# Step 2: Description
another command
```

**Why this is better:** [brief explanation]

Still want me to do it? (I can if you prefer)

### Exceptions (Execute Even If Simple)

- User explicitly says "do it for me" / "make the change"
- User seems stuck or frustrated
- Marginal token difference (file already read, <5K additional tokens)
- Part of larger complex task in progress

## Agent Usage

### When to Use Task Tool

```
Task(Explore)              → "How does X work?", architecture questions, open-ended exploration
Task(general-purpose)      → Multi-step research, complex searches
Direct tools               → Specific file/class lookups, known patterns
```

**Explore thoroughness:** `quick` | `medium` | `very thorough`

### Agent + Visual Workflow

**Use for:** Architecture questions, "how does X work?", system overviews

**Process:**
1. Launch Task(Explore) with: *"Return component list with file:line refs, flow sequence, key patterns"*
2. Convert findings to visual format (80/20 ratio)
3. Add prose only for decisions/gotchas

**Example:**
```
Agent output → List of components with locations and relationships
Your response → Flow diagram with arrows showing connections
```

### Skills + Agents

Combine for repeatable workflows in `.claude/commands/`:
1. Task(Explore) with structured output request
2. Convert to diagram per visual preferences
3. Add prose for decisions/gotchas
