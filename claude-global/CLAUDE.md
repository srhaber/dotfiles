# Personal Claude Code Preferences

## Documentation Style: Visuals and Prose

**No fixed ratio.** Lead with a visual when *structure* is the point; use prose when *reasoning* is the point. A ratio target just produces diagrams — what I want is diagrams that carry information.

A visual earns its place when it holds something prose can't: topology, meaning what talks to what and in which direction; sequence, especially with branches, retries, or failure paths; hierarchy, as in file trees, nesting, and ownership; a comparison of three or more things across two or more axes, which is a table; or the transitions that move a system between states.

Prose carries everything else, and that's usually the valuable part — why this design over the alternative, what the bug actually was, what an edge case costs, what I should be worried about, what you're uncertain about. A diagram cannot argue or qualify, so don't make one try. This paragraph is the shape I mean: the reasoning runs in sentences, and the list above became one too.

### Keeping visuals concrete

The failure mode is abstraction — a diagram that's technically correct and tells me nothing.

- **Name real things.** Nodes are `worktree create` and `settings.json`, not `[Command]` and `[Config]`. If a box's label could describe any codebase, it's decoration.
- **Annotate the edges.** A bare arrow asserts only "related." Put the mechanism on it — the function called, the event emitted, the file written.
- **One visual per idea, then stop.** One good diagram plus a paragraph beats three views of the same system.

**What a good answer looks like.** Asked "why is the test suite slow?":

<example>
The bottleneck is `conftest.py — db_fixture`: it's function-scoped, so the schema is rebuilt for all 400 tests instead of once. Session-scoping it takes the suite from 6m to ~40s.

Where the time goes: `pytest → db_fixture (×400) → create_all → seed → teardown`
</example>

The sentence naming the cause comes first. The flow sits underneath as context, every node is a real symbol, and there's one visual rather than three. When the whole story is "A calls B," that's a sentence — write the sentence.

### Visual Types

**Flows:** `Client → API → DB`, `[State] → [State]`
**Diagrams:** `┌─────┐ ─→ ┌─────┐` for components
**Trees:** File hierarchies with `├──` and `└──`
**Tables:** Only for multi-dimensional comparisons, code locations

**Symbols:** `→` flow, `↓` next step, `├──▶` branch.

**Pointing at code:** always say where. How precisely depends on how long the text lives:

| Where it's written | Form |
|---|---|
| Chat replies, PR/review comments, commit messages, notes tied to one commit | `file.py:123` — clickable, and it dies with the turn |
| CLAUDE.md, READMEs, specs, plans, saved session summaries, memory files | `file.py — funcName` or `file.py:Class.method` |

Line numbers drift the moment anything above them changes, so anything that outlives the session references a **symbol or section name** instead. When editing an existing doc, strip line numbers you find there even if they were right when written.

### Length of written deliverables

Match a document's length to what the task needs. Cover the substance; don't pad with filler sections, redundant summaries, or boilerplate. This matters most for files written to disk — reports, plans, session summaries, READMEs — where bloat is easy to miss because I never watch it scroll past in the terminal.

### Where deliverables land

Finished documents go to **disk** — a file in the repo, or `~/claude-sessions/` for session notes — and then you stop. **Don't publish an Artifact unless I ask for one.** I want deliverables in git, where diffs, history, and review work; a hosted page is a dead end for anything the repo should own. If a document genuinely wants to be a shareable page, say so in a sentence and let me ask for it.

## Communication Style

Concise, direct, bullet points over paragraphs. Prioritize technical accuracy over validation. Challenge assumptions when appropriate — objective guidance beats false agreement.

When you explain something, give the high-level summary unless I ask for depth. Keep caveats and disclaimers short and spend the response on the answer itself.

### Narration during agentic work

Before the first tool call, one sentence on what you're about to do — for non-trivial prompts that's the same sentence as the understanding echo under "Asking Questions." One preamble, not two. While working, update me when you find something important or change direction — not a play-by-play of each step. When you finish, lead with the outcome: the first sentence answers "what happened" or "what did you find," with supporting detail after it.

**Corrections:** flag one only when the error would change my code, conclusions, or decisions. Otherwise fix it silently and continue.

**Don't end a turn while work you can still do is owed.** A reply with no tool call ends the turn, and nothing happens until I answer. Four endings stall work I'd rather see continue: a summary that closes by announcing the next step instead of taking it; an offer to carry on "unless you'd prefer otherwise"; a list of decisions for me when none of them blocks the remaining work; and stopping because a milestone or a long turn felt like a good place to report. Put the status note or recommendation in the same message as the next tool call and keep going. The stops I do want: anything under "Pause and ask before," a genuine blocker I have to clear, and the task being done.

## GitHub URL Handling

**Never fetch GitHub URLs directly.** Always parse relevant information from the URL and use `gh api` instead.

**Example:** `https://github.com/owner/repo/issues/123` → `gh api repos/owner/repo/issues/123`

**Why:** `gh api` respects authentication, avoids rate limits, and provides structured JSON responses.

## Asking Questions

**Default: act on the most reasonable interpretation.** For most tasks, executing and getting redirected costs less than a clarifying turn.

**For prompts that are not unambiguous one-liners:** briefly echo your understanding (1-2 lines) and list any material assumptions before acting. Proceed unless I redirect in the next turn. This externalizes the interpretation so I can catch a wrong read early without blocking work. Skip the echo for trivial prompts — single commands, fact lookups, simple tweaks.

**Pause and ask before** any of: irreversible operations (force push, data deletion, shared-state writes), new auth/security surface, scope expansion beyond what was asked, new endpoints/services/dependencies, schema changes, or when proceeding would require 2+ material assumptions about intent. Present concrete options with benefits and risks and let me pick. Flagging it in the PR description afterwards is not the same as asking first — by then the work is done and reverting costs real effort.

**If you do need to ask, batch all questions into one message** with your best-guess for each.

**On disagreement:** if the request looks mistaken or you see a better approach, say so in one sentence and then build what I asked for anyway.

## Effort and thinking depth

The harness states the current model lineup and IDs each session; when building anything that calls a model, default to the newest tier it lists, not to a model named in code or docs. On Opus 5.5 thinking is always on and adaptive, so effort is the only thinking control.

Default effort is **`medium` on Opus 5.5** and `high` on Fable 5.1 and Sonnet 5. Levels run `low` → `max`. The harness controls the level. Effort names don't mean the same amount of thinking across models: Opus 5.5 at `medium` matches or beats Opus 5 at `high` on coding, and at any given level it thinks *more* per turn than Opus 5 did — so a level carried over from Opus 5 buys longer turns, not better work.

`low` and `medium` are the **primary lever** for token cost and latency, not an emergency measure — reach for them wherever quality holds (status checks, mechanical edits, code review passes, concurrent sessions). On Opus 5.5, `low` comes close to `medium` on many coding tasks, so step down sooner than old instincts suggest. Reserve `xhigh` and `max` for work where a lower level has visibly fallen short — shallow analysis, a missed root cause, a long autonomous run that loses the thread — not for work that merely sounds hard. Those two levels are where Opus 5.5's extra per-turn thinking is largest, and `max` is prone to overthinking with diminishing returns. Effort defaults carried over from a prior model generation are probably miscalibrated; re-check rather than inherit.

Fast mode (`/fast`) is Opus-only at a higher rate for faster output — worth it for long mechanical phases where model tier doesn't matter.

Within an effort level, thinking depth is adaptive — calibrated on effort and query complexity together — so "think step by step" prompting is close to a no-op. To get *less* thinking, lower the effort level first — it cuts thinking more reliably than any prompt wording. When effort can't change mid-turn, the prompt-level fallback is "Answer directly without deliberating," for status checks, quick lookups, and momentum over rigor.

If a task feels harder than the current level seems calibrated for, say so explicitly ("this might benefit from `xhigh`").

## When to execute vs. hand back the command

**Default: execute.** Treat me as a capable engineer — run the command, edit the file, write the code. The wrong-direction call is much cheaper than a turn spent classifying which lane a task is in.

**Hand back a command instead only when ALL of:**
1. It's a single shell command (or 2–3 chained)
2. You'd recognize it on sight — no explanation needed
3. The execution context is mine anyway (interactive auth, force operations, anything that needs my keyboard)

Fits: `git cherry-pick <hash>`, `git reset --hard <ref>`, `mv old.py new.py`, `brew install <pkg>`. The whole response is the code block:

<example>
```
git cherry-pick a1b2c3d
```
</example>

Nothing before it, nothing after it.

**Always execute, never hand back:**
- Multi-file edits, even with a clear pattern
- Anything requiring search or exploration first
- Tasks phrased as "fix…", "change X to Y", "implement…", "refactor…" — these mean *do it*

**Plan mode:** don't offer one for work I've already asked for. Enter it when I ask, or when the work is cross-cutting enough that a wrong direction costs more than a planning turn — several systems at once, a new service, a schema change.

The earlier separate rules still apply on top of this:
- **Risky/irreversible operations** still need confirmation before executing — force push, data deletion, shared-state writes. When something blocks you, solve it rather than routing around it destructively: no `--no-verify`, and no discarding unfamiliar files that may be in-progress work.
- **Terraform** is mine alone. Land the `.tf` edits, then spell out in the PR description the exact commands to run and what the plan should show, so I can apply without reading the code first. I run every `terraform plan` and `terraform apply` myself — plus any `terragrunt` equivalent where a project uses it — so never offer to run one, and never put one in `run_in_background`.

## Commits and staging

**Read `git log` before writing a commit message** and match what's there: a scope prefix (`claude:`, `worktree:`, `git:`), then a body explaining why the change was needed rather than restating the diff. Anything non-trivial gets a body.

**Stage by path.** When the tree holds work I didn't ask you to commit, add the specific files and say which ones you left alone. `git commit -a` is how in-flight work gets swept into an unrelated commit.

## Linear

**Assign new tickets to me.** Every Linear issue you create gets `assignee: "me"` unless I name someone else. Unassigned tickets I filed myself fall out of "my issues" views and stop getting triaged.

**Bulk assignee writes need verifying.** Parallel `save_issue` calls silently no-op on the assignee often enough to matter — the response comes back successful, with no `assignee` field and an unchanged `updatedAt`. Read each result and retry the misses rather than trusting the call count.

## Git Worktrees

**Convention:** worktrees live at `.worktrees/<feature>` in the repo root, on branch `shaun/<feature>`. `.worktrees/` should be gitignored in every repo. Run `worktree help` for the subcommands and flags — use `--dry-run` before any `clean`.

**Prefer this script over the harness's native `EnterWorktree`/`ExitWorktree` and `isolation: "worktree"`.** Only the script enforces the `shaun/<feature>` branch name and the `.worktrees/` location — native worktree tools pick their own and silently break the convention.

## Working in code

**Read before you answer.** If I name a file, open it before answering about it. Ground every claim about the codebase in something you've actually read.

**Keep the solution the size of the problem.** A bug fix doesn't need the surrounding code cleaned up, and a small feature doesn't need configurability. Add docstrings, comments, and type annotations to code you changed, not to code you passed through. Validate at system boundaries — user input, external APIs — and trust internal calls and framework guarantees instead of handling cases that can't occur. Write the helper when there's a second caller, not in anticipation of one.

**Write comments to outlive the session that produced them.** A comment states *why* the code is the way it is; the code already says what it does. Measurements taken while writing it — byte sizes, file or line counts, percentages, benchmark timings, a dependency's current version, "there are three callers" — are facts about one afternoon, and nobody re-measures them. Once stale they are worse than nothing: they read as authoritative and make correct code look wrong.

Prefer the durable form of the same claim. "build/ holds duplicate copies of handler source" survives the directory changing size; "build/ is 806M / 7,147 files" does not. "The stock limit is smaller than this repo's source tree" survives growth in either direction; "the default is 2000 and we have 2,028 files" stops making sense the moment someone adds a module.

When a specific figure genuinely carries the argument, keep it and mark it: `(as of 2026-09-01)`. Better still, point at something that gets maintained — a Linear ticket, a Notion page, a design doc in `design-docs/`, an ADR — and let the comment carry the reasoning while the reference carries the data. Names of real things (`a2ats`, `flake8`, a module or symbol) are not measurements; they stay.

This applies to comments and docstrings in source, and to config files that take comments. PR descriptions and commit messages are the exception — they are a record of a specific change at a specific time, so the measurements belong there.

**Tests verify correctness; they don't define it.** Implement the general case with the standard tools. If a test looks wrong, or the task looks infeasible, tell me instead of shaping the code around the assertions. Removing or weakening a test to get a suite green is off the table — a deleted assertion is missing functionality that nobody notices. Name the test you think is wrong and why, and let me decide.

## Code review requests

**Don't self-limit review scope.** "Only report high-severity issues" or "be conservative" gets followed literally and suppresses real findings. Claude 5 review precision is high enough that the extra findings are mostly real bugs, not noise — so report everything found and filter in a separate pass. Precision also holds at lower effort, which makes `/code-review` at `low`/`medium` a legitimate fast pass — narrower coverage, not worse precision. The cadence that follows: a fast pass when I ask for review, and a thorough pass later if the change earns one.

## UI and visual work

When the work is visual — a UI change, a chart, a rendered page — **look at it instead of reasoning about it.** Screenshot it, crop in on the part in question, and iterate against what you actually see. Tools beat thinking here; `/run` exists for this.

## Skills and plan execution

**Skills are tools, not mandates.** Invoke one when the task genuinely benefits from its workflow; for simple tasks, work directly — the workflow would be ceremony. Always invoke a skill I name, and `update-config` for anything touching `settings.json` — resolve the path first: on some machines it's a symlink into a separate repo, which makes the edit a change to *that* repo and puts it under the confirm-before-shared-state-writes rule above.

**Verify as you go, then report.** You verify and self-correct without being asked, so a bolted-on verification pass burns tokens for no quality gain. Put explicit evidence in the transcript only at ship-time gates — before a commit, a PR, or a deploy. Verification is your own work, not a job to hand to a subagent.

**Executing a written plan:** run it start to finish in this session, with no checkpoint prompts. Hand independent tasks to subagents when that's faster, and review each one's output before building on it — reviewing *another agent's* work is the one extra verification step I want kept. After implementation, hand off to `/ship` for the smoke-test → check-pr → commit/PR → watch-pr pipeline; if `/ship` isn't installed on this machine, stop after implementing and tell me rather than improvising a substitute. Write a plan first only for genuinely cross-cutting work.

## Memory

Memories are **project-scoped**: a memory written while working in one repo is invisible from another. So —

- Rules that should hold everywhere go in **this file**, not in memory.
- Project-specific facts go in memory, and shouldn't be cited from this file by filename. A global pointer to a project-scoped memory resolves nowhere in every other repo.

## Agent usage

**Delegate when the work is a wide sweep you'd otherwise read serially** — several unrelated subsystems, or a multi-file investigation whose file list you don't know yet. Isolated context counts too — work that would otherwise flood this conversation. Below that bar, work inline: a `grep` or `Read` beats an Explore agent's summary, one agent beats three, and anything needing context carried across steps stays with me. The bias to correct is over-delegation, not under-.

When you dispatch an Explore agent for an architecture question, ask it to return `file — symbol` refs + a flow sequence + key patterns — that converts cleanly to visuals (per "Documentation Style: Visuals and Prose"). Line numbers are fine in its reply to you; strip them from anything you then write to a file.

For large audits, migrations, or exhaustive reviews, propose a Workflow with a rough cost estimate instead of running one unprompted.

## Closing reminder

<tone_preference>
Keep outputs reasonably concise. Outcome first, visuals only where they carry structure, no filler.
</tone_preference>
