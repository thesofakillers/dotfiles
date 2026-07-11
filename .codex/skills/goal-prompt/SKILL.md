---
name: goal-prompt
description: "Write a standing goal prompt for working a Linear ticket to completion (TDD where it fits, atomic commits, empirical verification, implementation log). Use when Giulio invokes /goal-prompt with a ticket ID, asks for a goal prompt for a ticket, or asks to set up a goal to implement a Linear issue. Produces the prompt text only and does not start the work."
---

# Goal Prompt for a Linear Ticket

Generate the standing goal prompt Giulio gives to an implementation session. The
prompt tells that session to work one Linear ticket to completion under the house
rules, **without being prescriptive about implementation**: the ticket's own
description/checklist carries the "how"; the goal prompt carries the working
contract and definition of done.

Established exemplars: INF-7 (session "inf-7 storage capacity alerts") and
FLY-787 (session "Fix FLY-787: Nebius boot-disk leak on teardown").

## Inputs to gather before writing

1. **The ticket** (identifier from arguments/context; ask only if genuinely
   ambiguous). Fetch it with the `mcp__linear__*` MCP tools, preferably
   `mcp__linear__get_issue`; if those are unavailable, use the Linear GraphQL API
   with `LINEAR_API_KEY` from `~/.secrets`. Read the full description. Note: does
   it have settled-decisions / acceptance-criteria / checklist sections?
   Clarified tickets do; if the description is thin, say so to Giulio—a
   `/lin:clarify` pass may be worth doing first.
2. **The worktree**: current branch, its base (should be `origin/staging`), and
   any pre-existing dirty files (e.g. `.claude/seed/cache/*`) that must never be
   committed. If the branch is misnamed (`claude/*`), the goal prompt must
   include renaming it to `<ticket-id-lowercase>-<short-desc>`.
3. **TDD fit**: classify the ticket's work—pure logic (parsers, decision
   functions, renderers, math) is TDD territory; infra plumbing (CI wiring,
   sbatch, installers, config, docs) is not. Name both halves concretely in the
   prompt so TDD is required exactly where it fits and never forced.
4. **Verification split**: which acceptance criteria are verifiable pre-merge
   (tests, local runs, smoke) vs only post-merge/deploy (live alerts, cluster
   state, scheduled jobs)? Which require a human step (secrets, approvals)? Each
   goes in the prompt explicitly.

## Prompt skeleton

Emit exactly this shape, filled in for the ticket (INF-7's prompt is the
canonical instance). Keep it ~25–40 lines; no implementation steps, no
restating the ticket's checklist.

```
Work on Linear issue <ID> (<URL>).

The ticket is the spec. Always start by reading it in full — the description
carries the settled decisions, scope, acceptance criteria, and the
implementation checklist. Do not reopen decisions recorded there. If you hit
something the ticket genuinely doesn't answer and it isn't resolvable
empirically, ask Giulio rather than deferring it into a TODO comment or
guessing.

How to work:
- You are on branch `<branch>` in this worktree, based on origin/staging.
  The PR targets staging; this ticket maps to exactly one PR. Add the
  codex-review-requested label at PR creation. <Note any pre-existing dirty
  files to never commit. If branch needs renaming, say so here.>
- Commits are authored by Giulio only — no AI attribution, no Co-Authored-By
  trailers, no claude/* branch names.
- Atomic commits throughout — one logical concern per commit, as you go, not
  a batch at the end.
- TDD where it fits: <name the pure-logic parts of THIS ticket> is
  test-first territory. <Name the plumbing parts> is not — don't force it;
  use <the ticket's fallback verification: smoke tests, harness, renders>.
- Be empirical before declaring anything done: <the ticket's concrete
  verification paths>. Some criteria are only observable post-merge
  (<list them>) — get everything pre-merge verifiable green and state in
  the PR which criteria remain post-merge and how to check them. Never
  claim a criterion is met that you haven't observed.
- <Human-step dependencies, if any: what they are, degrade gracefully,
  flag rather than silently block.>
- Linear hygiene: <ID> In Progress at start, In Review at PR. Never set
  Done manually — the Linear/GitHub automation transitions it when the PR
  merges (SOC2 audit trail). Don't merge without Giulio's go-ahead.
- When the work is complete, record it on <ID> with an evidence-backed
  implementation log (/lin:append-implementation-log).
```

## Rules

- **Non-prescriptive**: constraints and outcomes only. If you find yourself
  writing "step 1 / step 2" or naming functions to create, delete it—that
  belongs in the ticket.
- **Ticket-specific, not boilerplate**: the TDD-fit, verification-split, and
  human-step bullets must name this ticket's actual content. If a bullet would
  be generic filler for this ticket (e.g. no human steps), drop it.
- **The prompt must stand alone**: a fresh session with no context must be able
  to act on it. Include the full ticket URL and real branch name.
- **Deliver, don't execute**: hand the prompt back in a fenced block for Giulio
  to use (plus at most one line noting anything you noticed, such as a thin
  ticket or misnamed branch). Do not start the implementation, create or update
  a Codex goal, or execute the emitted prompt unless he explicitly asks.
