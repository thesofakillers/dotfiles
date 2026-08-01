# Generic Instructions

When available, read up on README.md to familiarize yourself with what we're
doing and how we're doing it.

When developing python:

- you almost always probably need to prefix your command with `uv run`. See
  <https://docs.astral.sh/uv/> for reference.
- always prefer absolute imports over relative imports, e.g.
  `from foo.bar import Baz` instead of from `.bar import Baz`.
- Use type hints wherever possible, and avoid using `Any` and `cast` if
  possible.
- Use pytest for testing if testing.
- If working in a monorepo structure, most likely you will have to cd into the
  project directory for running things for a specific project
- If available, run the pre-commit hooks (dont actually commit, just run them).

When using sentry:

- Avoid using the natural language search. You should be able to navigate to the
  relevant events using vanilla CLI arguments and/or the API. The natural
  language search is slow and should be avoided.

## Realtime Voice Coordination

During realtime voice conversations, keep the coordinator responsive and
focused on the live conversation:

- Keep only conversational responses, clarification, context-building, and
  genuinely immediate non-blocking control actions local.
- Without waiting for the user to ask, delegate any self-contained workstream
  that should remain independently visible, revisitable, or steerable, even
  when it appears short. This includes connector and research work.
- Prefer treating requests for a "thread", "Codex thread", "different thread",
  or "new thread" as requests for a real Codex worker thread. If a subagent is
  a better fit, identify it clearly rather than implying it is a durable Codex
  thread.
- Reuse the existing owning Codex thread for follow-ups. Use project-bound
  Codex threads for repository-specific or stateful work, and projectless Codex
  threads for workspace-independent work.
- Create new Codex threads on the coordinator's current Codex instance and host
  by default unless the user explicitly selects another host. Verify the
  returned host and target rather than assuming the dispatch landed locally.
- Prefer subagents for genuinely ephemeral internal parallelism, especially
  when the user explicitly requests subagents or parallel agents or when
  applicable instructions require them. Keep durable user-visible workstreams
  in Codex threads by default.
- Treat the latest clear request as authoritative. When the user interrupts or
  changes topic, stop the stale response and do not repeat it.
- Immediately report successful dispatches by human-readable task name and,
  when relevant, host. Accurately distinguish Codex threads from subagents.
  Describe task state as starting, running, blocked with a specific need, or
  complete; do not call running work queued or pending.
- Assume the user may not see the screen. Lead spoken responses with the answer
  and leave lengthy details in text for later. Continue the conversation while
  delegated work runs and surface concrete progress, blockers, decisions, and
  final results.

## Repo-specific Instructions

Of course, you should also follow any repo-specific instructions and, if
present, AGENTS.md file(s), which you should look for in the repo you are
working in.

## Secrets

Keep in mind that ~/.secrets has been sourced, setting a number of env vars that
can help or get in the way of developing. Be aware of it when working.

## Git Workflow Defaults

- Never prefix branch names with `codex/`; use the requested ticket or task
  branch name directly (for example, `res-174-hrm-text`).
- Avoid rebases unless the user explicitly asks for a rebase.
- Avoid force pushes (including `--force-with-lease`) unless the user explicitly asks for one.
- When bringing target branch updates into a feature branch, prefer merge (for example: merge `staging` into the current branch) instead of rebasing.

## Email Defaults

- Do not send emails unless the user explicitly asks you to send that specific email.
