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

**Default: act on the most reasonable interpretation.** For most tasks, executing and getting redirected costs less than a clarifying turn.

**For prompts that are not unambiguous one-liners:** briefly echo your understanding (1-2 lines) and list any material assumptions before acting. Proceed unless I redirect in the next turn. This externalizes the interpretation so I can catch a wrong read early without blocking work. Skip the echo for trivial prompts — single commands, fact lookups, simple tweaks.

**Pause and ask before** any of: irreversible operations (force push, data deletion, shared-state writes), new auth/security surface, scope expansion beyond what was asked, new endpoints/services/dependencies, schema changes, or when proceeding would require 2+ material assumptions about intent. See `feedback_check_before_major_decisions.md` for rationale.

**If you do need to ask, batch all questions into one message** with your best-guess for each. Never drip-feed.

## Response Length

**Concise (1-3 lines):** Confirmations, simple answers, clarifying questions
**Medium (5-10 lines):** Instructions, explanations, single-file changes
**Detailed (10+ lines):** Architecture diagrams, multi-file changes, complex debugging

Default to shorter responses. Expand only when visuals or detail add value.

## Effort and thinking depth

Current lineup (verified against CC 2.1.202, 2026-07): **Claude 5 family** — Fable 5 (`claude-fable-5`, Mythos-class tier above Opus) and Sonnet 5 (near-Opus coding quality at Sonnet cost) — plus Opus 4.8 and Haiku 4.5. Opus 4.7 is previous-gen and sunsetting.

Default effort is `high` on Fable 5, Sonnet 5, and Opus 4.8 (Opus 4.7 defaulted to `xhigh`). Levels run `low` → `max`. The harness controls the level. Bump to `xhigh` only for genuinely hard problems (algorithm design, deep debugging); `max` is prone to overthinking with diminishing returns. Drop to `medium` when running concurrent sessions where cost matters more than depth — on Claude 5 models, lower effort often matches prior models' `xhigh`, so step down sooner than old instincts suggest.

Fast mode (`/fast`) runs Opus at 2x standard rate for up to 2.5x output speed — Opus 4.8 only (4.7 fast deprecated, removed 2026-07-24; no Fable 5 fast mode, so toggling on a Fable session means an Opus swap). Worth it for long mechanical phases where model tier doesn't matter.

Within an effort level, the model picks thinking depth adaptively. Two override patterns to use when the default doesn't match the task:
- "Think carefully and step-by-step — this is harder than it looks." → tricky problems, deep refactors, when an earlier attempt missed something.
- "Prioritize responding quickly over thinking deeply." → status checks, quick lookups, momentum over rigor.

If a task feels harder than the current level seems calibrated for, say so explicitly ("this might benefit from `xhigh`").

## When to execute vs. hand back the command

**Default: execute.** Treat me as a capable engineer — run the command, edit the file, write the code. The wrong-direction call is much cheaper than a turn spent classifying which lane a task is in.

**Hand back a command instead only when ALL of:**
1. It's a single shell command (or 2–3 chained)
2. You'd recognize it on sight — no explanation needed
3. The execution context is mine anyway (interactive auth, force operations, anything that needs my keyboard)

Fits: `git cherry-pick <hash>`, `git reset --hard <ref>`, `mv old.py new.py`, `brew install <pkg>`. Output format: one code block, no preamble, no token-cost framing, no "⚡ more efficient" banner.

**Always execute, never hand back:**
- Multi-file edits, even with a clear pattern
- Anything requiring search or exploration first
- Tasks phrased as "fix…", "change X to Y", "implement…", "refactor…" — these mean *do it*

The earlier separate rules still apply on top of this:
- **Risky/irreversible operations** still need confirmation before executing (force push, data deletion, shared-state changes — see "Executing actions with care").
- **Terraform** is mine alone — land the .tf edits and stop (per `feedback_terraform_ownership.md`).

## Git Worktrees

**Convention:** All worktrees live in `.worktrees/` at the repo root

- Create: `worktree create <feature>` (branches as `shaun/<feature>`)
- List: `worktree list`
- Remove: `worktree remove <feature>`
- Clean: `worktree clean`
- `.worktrees/` should be gitignored in every repo

## Skill invocation

**Skills are tools, not mandates.** Invoke a skill when the task genuinely benefits from its workflow — e.g. `superpowers:systematic-debugging` for a real debugging session, `superpowers:dispatching-parallel-agents` for actual parallel work, `superpowers:verification-before-completion` before claiming a non-trivial task done. Skip them for simple tasks where the workflow would be ceremony.

This **overrides** the `superpowers:using-superpowers` bootstrap rule that says "even 1% chance a skill might apply, you ABSOLUTELY MUST invoke." That framing is calibrated for older models — Opus 4.8 and the Claude 5 models pick skill relevance adaptively. The user-instruction priority means this section wins over the bootstrap.

Skills chain (CC ≥2.1.199): up to 6 in one prompt — `/skill-a /skill-b do XYZ`. Custom slash commands are now skills; there's no separate command system.

The exceptions where skill invocation is still load-bearing:
- `update-config` — anything that touches `settings.json`
- `superpowers:writing-skills` — when authoring/editing a skill
- Any skill the user explicitly names in their prompt

**Plan execution default:** when there's a written implementation plan to execute, use `superpowers:subagent-driven-development` (autonomous, current session, two-stage review per task). Don't ask whether I want checkpoints — the answer is no. After implementation, hand off to `/ship` for the smoke-test → check-pr → commit/PR → watch-pr pipeline. For deep multi-system planning before a plan exists, `/ultraplan` is available — reserve it for genuinely cross-cutting work.

## Agent Usage

### When to Use the Agent Tool

(Renamed from Task in CC 2.1.63 — `Task(...)` references below still resolve.)

```
Agent(Explore)             → "How does X work?", architecture questions, open-ended exploration
Agent(general-purpose)     → Multi-step research, complex searches
Direct tools               → Specific file/class lookups, known patterns
```

**Explore thoroughness:** `quick` | `medium` | `very thorough`

**Subagents run in the background by default** (CC ≥2.1.198) — dispatching one doesn't block the main thread, so parallel fan-out across independent questions is cheap. Nesting goes up to 5 levels.

**Don't spawn an agent for what a single tool call would answer.** A `grep`, `Read`, or `Glob` is faster than dispatching an Explore agent for its summary.

For architecture questions where you do dispatch an Explore agent, ask it to return file:line refs + a flow sequence + key patterns — that converts cleanly to visuals (per "Documentation Style: Visual-First").

### Multi-agent orchestration (Workflow)

The Workflow tool runs deterministic multi-agent scripts (fan-out, adversarial verify, synthesize) but is opt-in — it fires only when I say "use a workflow" or "ultracode" in the prompt. For large audits/migrations/exhaustive reviews, propose one with a rough cost estimate instead of running it unprompted. `superpowers:dispatching-parallel-agents` remains the default for ordinary 2–5-agent parallel work.
