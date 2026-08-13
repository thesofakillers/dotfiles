---
name: codex-double-review
description: >
  Run Giulio's independent two-pass Codex review and integrate only validated
  findings: one standard correctness pass through non-interactive `codex exec
  review`, plus one ponytail over-engineering pass through plain `codex exec`
  over the same embedded diff. Use when Giulio says "double review", "codex
  double review", "/review + ponytail", asks for a review and ponytail review,
  or requests the usual pre-PR review pass before finalizing a PR.
---

# Codex Double Review

Run two fresh, independent review subprocesses over the same target, then act as
the orchestrator and integrator. Never perform either review inline in the
orchestrating Codex session. The correctness pass hunts bugs; the ponytail pass
hunts over-engineering. Keeping their contexts separate is the point.

## 1. Select one review target

Inspect the repository and choose exactly one target for both passes:

- Use `--base <ref>` for committed branch work. If the branch has not been
  reviewed yet, use the merge target (`staging` in paradigma; otherwise the
  explicit target, default branch, or branch implied by the merge base). If an
  earlier double review already covered the branch, use the exact previously
  reviewed head commit as the base and review only commits added since it. Use
  prior review output or the user's statement as evidence; do not infer that a
  commit was reviewed.
- Use `--uncommitted` for staged, unstaged, and untracked work.
- Use `--commit <sha>` for one commit.

If the choice is ambiguous, especially when committed branch work coexists with
stray uncommitted files, state the chosen target and why before launching the
reviews. Do not silently combine targets. Both reviewers must cover the same
diff.

Materialize the ponytail pass's exact diff before launching either subprocess.
Run the corresponding `git diff --stat` first; if it unexpectedly includes
already-reviewed work, correct the target instead of repeating the review.

- Merge-base target: `git diff origin/<base>...HEAD`.
- Incremental target: `git diff <previous-reviewed-head>...HEAD`.
- Commit target: use the patch introduced by `<sha>`.
- Uncommitted target: include staged, unstaged, and untracked files, matching
  the semantics of `codex exec review --uncommitted`; ordinary `git diff` alone
  omits untracked files.

Do not fetch to build the diff. If the required local base ref is missing or
ambiguous, stop and ask which local ref to use.

## 2. Launch both independent reviews

Use nested, non-interactive `codex exec` shell subprocesses. Authentication is
shared through `~/.codex`. Let model and reasoning effort come from
`~/.codex/config.toml`; never pin or override either unless Giulio asks.

Create a durable temporary output directory with `mktemp -d`. Build a ponytail
prompt file containing the local-only instruction, the exact instruction block
below, and the materialized diff in a fenced `diff` block. Then start both
commands as background jobs before waiting for either:

```bash
scratch="$(mktemp -d)"

codex exec review --base staging \
  >"$scratch/codex-review.md" 2>&1 &
correctness_pid=$!

codex exec -s read-only - \
  <"$scratch/ponytail-prompt.md" \
  >"$scratch/ponytail-review.md" 2>&1 &
ponytail_pid=$!

wait "$correctness_pid"
correctness_status=$?
wait "$ponytail_pid"
ponytail_status=$?
```

Replace the example correctness target with the selected `--base`,
`--uncommitted`, or `--commit` form. Preserve both exit statuses and raw output
files. If the shell uses `set -e`, temporarily arrange the waits so a failed
first job does not prevent collecting the second job's result.

`codex exec review` in Codex CLI 0.144.1 rejects `--base` combined with a
custom prompt. Therefore, never use the ponytail instructions as a custom
`review` prompt. Run them through plain `codex exec -s read-only` with the diff
embedded in stdin. Precede the block with this explicit instruction:

```text
The diff is embedded below. Do NOT fetch from GitHub or use MCP tools; use
local files only for surrounding context.
```

Embed this ponytail instruction block verbatim:

```text
Review ONLY for over-engineering and unnecessary complexity. Correctness,
security, and performance are out of scope for this pass. Find what to
delete: reinvented standard library, unneeded dependencies, speculative
abstractions, dead flexibility, config nobody sets, layers with one caller.
One line per finding, format `<file>:L<line>: <tag> <what>. <replacement>.`
with tags delete / stdlib / native / yagni / shrink. A single smoke test or
assert-based self-check is the minimum, never flag it for deletion. End with
`net: -<N> lines possible.` or, if there is nothing to cut, exactly
`Lean already. Ship.`
```

Nested `codex exec` may require the outer Codex session to obtain sandbox or
approval escalation to launch it or access the repository. Request that
escalation rather than silently weakening the commands. If `codex` is missing,
unauthenticated, either subprocess cannot run, or the current sandbox cannot
run nested `codex exec` at all, stop and report the failure. Never substitute
an inline self-review.

## 3. Validate claims, then integrate

Treat every finding as a claim, not an order. Read both raw outputs, enumerate
their findings, and validate each against the current code plus recorded
ticket/PR decisions before editing.

- If `review:validate-review-claims` is available in the repository, invoke it
  and follow it. Otherwise perform equivalent evidence-bound validation.
- Apply only findings that still hold and fit the change's recorded intent.
- Skip each wrong, stale, out-of-scope, or decision-conflicting finding with a
  one-line reason.
- Automatically skip any ponytail finding that would delete a deliberate
  `ponytail:`-commented shortcut or the change's only test.

After integration, rerun the narrowest lint, typecheck, and test commands that
cover the touched code. Commit fixes in small atomic commits following the
repository's conventions, with no AI attribution. Push or update a PR only
when the user's request authorizes those external writes.

## 4. Report

End with all of the following:

- Applied findings, grouped by resulting commit.
- Skipped findings, each with a one-line reason.
- Absolute paths to `codex-review.md` and `ponytail-review.md`.
- Checks rerun and their pass/fail results.
