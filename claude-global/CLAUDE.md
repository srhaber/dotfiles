# Personal Claude Code Preferences

This file contains personal preferences that apply across all projects.

## Documentation Style Preferences

I strongly prefer visual representations (tables, diagrams, flow charts) over prose when explaining technical concepts, architecture, or relationships. Visuals make information more scannable and faster to understand.

### Visual vs Prose Guidelines

**For architecture/system documentation:** Target 80% visuals, 20% prose
**For general conversation:** Use visuals liberally when they clarify concepts

**Rule of thumb:** Use the format that makes information most accessible. When in doubt, try a table first - you can always add prose if needed.

### When Visuals Work Best

Sessions/topics that benefit most from visual representation:
- Architecture reviews and system design
- Handler/trigger/event mappings
- Database access patterns and schemas
- System flows and data flows
- Configuration comparisons
- Event routing
- File structures and organization
- State transitions

### When Prose Is Appropriate

Sessions/topics that may need more prose:
- Debugging investigations (thought process, investigation steps)
- Decision discussions (weighing tradeoffs, rationale)
- Conceptual explorations and brainstorming
- Code review discussions with nuanced feedback
- Edge cases and gotchas (explaining HOW to avoid, not just listing)
- Context and narrative (what prompted this work)
- Insights and learnings (synthesizing observations)

### Visual Types - Use Liberally

**1. Flow Diagrams** - For processes, sequences, and data flows:
```
Client → API → Database
  ↓
Response
```

**2. State Machines** - For lifecycle and transitions:
```
[Created] → [Processing] → [Complete]
                ↓
            [Failed]
```

**3. Architecture Diagrams** - For system components:
```
┌─────────┐     ┌─────────┐
│ Service │────▶│  Queue  │
└─────────┘     └─────────┘
```

**4. Tree Structures** - For file hierarchies and decision trees:
```
src/
├── handlers/
│   ├── connect.py
│   └── default.py
└── utils/
```

**5. Tables** - Use selectively when comparing structured data with multiple attributes:
| Component | Purpose | Dependencies |
|-----------|---------|--------------|
| foo.py    | Auth    | Firebase     |

Note: Prefer diagrams and flows over tables when possible. Use tables when:
- Comparing multiple items across several dimensions
- Listing code locations with line numbers
- Showing configuration options side-by-side

### Documentation Best Practices

1. **Start with a diagram** - For flows, processes, and architecture, use diagrams first
2. **Flows over prose** - Don't describe processes in text when arrows work better
3. **Use consistent symbols** - `→` for flow, `↓` for next step, `├──▶` for branching
4. **Include line numbers** - Always reference code with `file.py:123` format
5. **Visual summaries** - Begin explanations with a visual summary, then add prose details if needed
6. **Adapt to content** - Don't force visuals where prose is clearer
7. **Tables sparingly** - Use tables only when comparing structured data across multiple dimensions

## Session Documentation

When documenting sessions (via `/save-session`):
- For architecture/system sessions: Lead with diagrams and flows (80/20 visual/prose ratio)
- For debugging/discussion sessions: Use natural mix based on content
- Always use prose for "Decisions Made" and "Learnings & Insights" sections
- Add visual summaries to "Outcomes" (✅, ⚠️, 💡 for categories)
- Use tables selectively for comparisons or code location references when they add clarity

## Communication Style

- Be concise and direct
- Use bullet points over paragraphs when listing items
- Avoid over-the-top validation ("You're absolutely right" → just answer the question)
- Prioritize technical accuracy over emotional validation
- Challenge assumptions when appropriate, even if not what I want to hear
- Objective guidance and respectful correction are more valuable than false agreement
