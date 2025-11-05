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

## Agent Usage

### When to Use Task Tool

```
Task(Explore)              → "How does X work?", architecture questions, open-ended exploration
Task(general-purpose)      → Multi-step research, complex searches
Direct tools               → Specific file/class lookups, known patterns
```

**Explore thoroughness:** `quick` | `medium` | `very thorough`

### Agent + Visual Workflow

Request structured output: *"Return component list with file:line refs, flow sequence, key patterns"*

Then convert findings to visual format (80/20 ratio).

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
