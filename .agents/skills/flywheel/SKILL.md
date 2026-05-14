---
name: flywheel
description: General Flywheel guidance for experiment design, MCP/tool-contract questions, and setup or troubleshooting across supported hosts. Use for platform support or cross-cutting guidance, not concrete graph-authoring tasks covered by the specialized Flywheel skills.
---

# Flywheel Skill

Use this skill to structure research work and to route setup/support questions to the smallest relevant Flywheel docs.

## When To Use

Use this skill when the conversation is about any of the following:

- planning experiments, hypotheses, comparisons, or next-branch decisions
- running or interpreting empirical work in Flywheel
- choosing between `insight` and `empirical` nodes
- setting up, updating, authenticating, or troubleshooting Flywheel MCP
- configuring hooks, hook secrets, and hook-run monitoring
- managed compute, local hardware, campaigns, or Flywheel Web UI navigation

If the request is ambiguous, default to experiment-design guidance before platform mechanics.

## Modes

This skill supports both Flywheel install modes:

- **`--mode mcp` install**: route via [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md); tool calls take the form `flywheel_<tool>` (e.g., `flywheel_commit_node`).
- **`--mode cli` install**: `setup --mode cli` configures runtime credentials, then route via [references/flywheel-cli-tool-map.md](references/flywheel-cli-tool-map.md); tool calls take the form `flywheel <command>` (e.g., `flywheel nodes:commit`). Prerequisite for bare-binary routing: run the curl installer with `--mode cli` or use the managed-prefix npm install recipe from the README.

When switching an already-configured host between modes, rerun setup with `--force` (or uninstall first) so prior-mode artifacts are reconciled explicitly.

The Workflow and Routing Map below cite both the MCP tool name and its CLI equivalent inline at each imperative step. Pick the one matching your install mode.

## Workflow

1. Classify the request as research guidance, platform support, or mixed.
2. Load only the minimum files needed for the current task.
3. For research requests, run a short design pass before execution:
   ask 1-2 questions to clarify objective, assumptions, and decision criteria.
4. If design is solid and the user wants to proceed, shift to execution support.
5. Use Flywheel MCP tools for live behavior/contract checks when available.
6. Summarize evidence and propose the most likely next branch.

## Routing Map

Choose one primary file first, then add at most one supporting file only if needed:

- `references/experiment-design-protocol.md` for structured experiment design and readiness checks
- `references/flywheel-mcp-tool-map.md` (MCP) or `references/flywheel-cli-tool-map.md` (CLI) for exact tool surface and contract behavior in the matching install mode
- `getting-started/flywheel-tutorial-overview.md` for orientation and learning path
- `getting-started/flywheel-quickstart.md` for fastest first-use setup and auth recovery
- `setting-up-flywheel/` for host-specific installation and update procedures
- `usage-and-workflows/` for practical workflows and local hardware
- `compute/` for managed compute and billing/credits
- `campaigns/` for campaign participation
- `web-ui/` for web UI guides and maps
- `example-workflows/` for concrete, end-to-end examples

## Guardrails

- Keep guidance harness-agnostic unless the user explicitly asks for a specific host.
- Prefer concrete steps and decision points over long narrative explanations.
- Do not run broad document reads; load only what is required by the current request.
- Do not start compute-heavy execution before design intent is clear.
- When another specialized Flywheel skill is explicitly invoked, this skill provides background guidance only and must not override that skill's workflow rules.
- For managed compute cleanup in autonomous runs, default to releasing only
  known leases (leases acquired in the current run or explicitly selected by
  the user).
- When unknown active leases are present, report and skip by default.
- Use `flywheel_compute_release_all` for token-scoped bulk cleanup with the
  active `lease_control_token`; add `force=true` only when the user explicitly
  asks for account-wide cleanup.
- Respect Flywheel write limits. Current per-user limits are 120 node creates
  per minute, 2,000 node creates per 24 hours, and 120 graph writes per minute.
  Graph writes include existing-node edits, parent edge changes, deletes,
  merges, tag/sharing changes, artifact finalization, artifact deletion, and
  artifact-note updates. If a write returns `429`, honor `Retry-After` before
  retrying the same idempotent request; do not spin in a tight retry loop.
