---
name: flywheel-lookahead
description: Plan the next Flywheel frontier from existing graph state by persisting a control node, explicit option nodes at each hop, and one selected continuation chain, without execution or compute acquisition. Use when Codex needs planning-only Flywheel graph authoring, `n`/`k` lookahead, or graph-native comparison of candidate next steps, not claim validation, source-to-graph authoring, or autonomous execution.
---

# flywheel-lookahead

## When To Use

The frontmatter description owns trigger semantics. Once invoked, use this skill only for planning-only Flywheel frontier authoring: persist a control node, hop-selector nodes, and explicit option nodes from existing graph state without hidden execution, compute approval, or managed compute acquisition.

If exact tool or field semantics are unclear, load [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md) and [references/INTERFACES.md](references/INTERFACES.md) before mutating nodes.

## Modes

This skill supports both Flywheel install modes:

- **`--mode mcp` install**: route via [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md); tool calls take the form `flywheel_<tool>` (e.g., `flywheel_commit_node`).
- **`--mode cli` install**: `setup --mode cli` configures runtime credentials, then route via [references/flywheel-cli-tool-map.md](references/flywheel-cli-tool-map.md); tool calls take the form `flywheel <command>` (e.g., `flywheel nodes:commit`). Prerequisite for bare-binary routing: run the curl installer with `--mode cli` or use the managed-prefix npm install recipe from the README.

When switching an already-configured host between modes, rerun setup with `--force` (or uninstall first) so prior-mode artifacts are reconciled explicitly.

The Workflow below cites both the MCP tool name and its CLI equivalent inline at each imperative step. Pick the one matching your install mode.

## Input Contract

Before planning, recover or establish these inputs:

- Required before planning: start nodes, objective, lookahead depth `n`, step option width `k`, and an explicit terminal condition.
- Optional: budget ceiling and budget unit, but only when the user already supplied them or wants them tracked for later execution.
- Defaults: `lookahead_depth` defaults to `n=1`; `step_option_width` defaults to `k=1`.
- Recovery rules:
  - Ask only when a required planning input cannot be recovered from explicit user instructions, current conversational context, or recent graph state.
  - If start nodes cannot be recovered from explicit ids/slugs, named current context, or recent graph context, ask once.
  - If the objective is missing, ask once; if the user refuses, infer it from graph context and persist it before planning.
  - If the terminal condition is missing, ask once; if it remains unspecified, persist a planning-local terminal condition such as stopping after staging this lookahead pass through the requested `n` hops with at most `k` considered options per hop and one selected continuation per hop.

## Working Terms

- `frontier`: the current unresolved next-step nodes or candidate branches worth planning next.
- `resolved frontier`: the latest resolved nodes from which the next frontier should be expanded, not the original source corpus again.
- `control node`: the dedicated `insight` node that stores the canonical planning contract for the current frontier.
- `terminal condition`: the explicit condition that tells this planning pass when to stop staging additional frontier nodes.
- `expected_revision`: the node's current revision token used for optimistic-locking writes.
- `lookahead depth (n)`: the number of sequential hops in one planned path.
- `step option width (k)`: the number of candidate directions evaluated at each hop before choosing one continuation.

## Width Semantics (Unambiguous)

- Lookahead depth `n`: number of sequential hops in one plan path.
- Step option width `k`: number of candidate directions to evaluate at each hop.
- Expansion rule: at hop `i`, generate up to `k` non-redundant options, select exactly 1 winner, and only that winner continues to hop `i+1`.
- Graph shape for this mode: a single chain of `n` hop-selector nodes, each with up to `k` explicit option nodes (not `k` parallel continuation chains).
- Each considered option should normally be staged as its own node when it is a stable, non-redundant candidate direction. Do not collapse the `k` options into prose only.
- The next hop should keep the current hop-selector node as a parent and add the chosen option node as an additional selected edge/parent when the topology can express that relationship.
- Each step node must record:
  - the `k` considered options,
  - the selection criterion,
  - the chosen continuation.

## Core Rules

- Treat the main page body as the node readme/body field (`content` on modern Flywheel surfaces).
- Use artifacts for supporting files and evidence, not as a substitute for the node's main narrative, because the node body should stay readable as the canonical planning record.
- Only create graph edges for durable semantic relationships, because graphifying every wiki link floods the graph with noise that hides decision-relevant structure.
- Treat the flywheel-lookahead skill as frontier planning only. It expands the Flywheel graph with staged next-step nodes but does not execute them, because execution or compute acquisition changes the job into `$flywheel-auto` or `$flywheel-reproduce`.
- Planned nodes that are expected to produce evidence or artifacts should say so in `content` and attach artifacts when evidence exists; planned nodes that encode synthesis, decomposition, or decision structure should keep that rationale in `content`.
- Ask only the minimum clarification questions needed to establish a coherent planning contract, and ask none when the required answers are already recoverable from user instructions, conversational context, or graph state.
- Do not request compute approval, acquire managed compute, or launch execution in this skill, because planning should leave the frontier staged for later work rather than spend budget now.

## Workflow

1. Resolve the starting context.
   - Resolve starting nodes in this order: explicit node ids/slugs, explicitly named current context, focused or recently referenced nodes, then ask the user if nothing stable is recoverable.
2. Resolve the planning contract.
   - Recover required planning inputs from the current conversation and graph first. Ask only for inputs that remain genuinely missing after that recovery pass.
   - The flywheel-lookahead skill requires a measurable objective. Ask once if it is missing; if the user refuses to specify one, infer it from the available graph context and state it explicitly before continuing.
   - Default `n=1` and `k=1` unless the user specified otherwise.
   - Persist the planning contract in a dedicated control node for this frontier. Put the canonical contract and brief planning rationale in node `content`, and keep a one-line synopsis in `summary`.
   - The control contract must name: objective, decision criterion, start nodes, lookahead depth `n`, step option width `k`, and an explicit terminal condition. Only persist a budget ceiling and unit when the user already supplied one or wants them tracked for later execution.
   - Later lookahead passes must read the control node `content` first and continue from that persisted contract rather than from chat memory.
3. Map each stable page, claim, or concept to a node.
   - For exact node-mutation shapes, load [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md).
   - In this skill, each stable considered direction at a hop should normally become its own option node; the hop-selector node remains the decision record for that hop.
   - Prefer `flywheel_commit_new_node` (MCP) or `flywheel nodes:commit-new` (CLI) for a new standalone control or planning node when there is no existing parent to branch from.
   - Prefer `flywheel_branch_node` (MCP) or `flywheel nodes:branch` (CLI) for hop-selector nodes or option nodes that should attach directly under an existing control node, frontier node, or winning option node.
   - Update an existing node with `flywheel_get_node`, `flywheel_acquire_stage_lease`, and `flywheel_commit_node` (MCP) or `flywheel nodes:get`, `flywheel nodes:stage:lease:acquire`, and `flywheel nodes:commit` (CLI).
   - Use `flywheel_add_parent` (MCP) or `flywheel nodes:add-parent` (CLI) when the chosen option should remain recoverable in topology as an additional parent or selected edge, not prose alone.
4. Put the primary page markdown or plan rationale in the node body/readme field (`content`).
   - Put claims, rationale, methods, outcomes, and continuation notes in `content`; keep `summary` concise.
5. Publish supporting files with the artifact upload flow.
   - For exact artifact contract details, load [references/ARTIFACTS.md](references/ARTIFACTS.md).
   - Use `flywheel_prepare_artifact_uploads` (MCP) or `flywheel artifacts:upload:prepare` (CLI).
   - Upload raw file bytes to the returned signed URLs.
   - Call `flywheel_finalize_artifact_uploads` (MCP) or `flywheel artifacts:upload:finalize` (CLI) once all uploads in the batch are staged.
   - Keep the artifact filename stable enough to reference from markdown when inline rendering matters.
6. Add graph structure sparingly.
   - Promote only decision-relevant relationships to edges.
   - Leave ordinary cross-links inside the markdown body.
7. Expand the frontier as a single selected path.
   - Expand from the resolved frontier rather than mirroring the source corpus again.
   - Depth `n` means plan `n` sequential hops ahead from the currently resolved frontier. Default `n=1`.
   - Width `k` means evaluate up to `k` distinct non-redundant candidate directions at each hop. Default `k=1`.
   - At each hop, stage up to `k` explicit option nodes, record them in the hop-selector node, apply the selection criterion, and choose exactly one continuation.
   - Only the chosen continuation advances to hop `i+1`; do not stage `k` parallel continuation chains for this mode.
   - The staged graph shape for this mode is a single chain of up to `n` unresolved hop-selector nodes (shorter only when the terminal condition is met early), with up to `k` option nodes attached to each hop.
   - When one option wins, encode that choice in topology as well as prose: the next hop should be reachable from the chosen option node via a selected edge or additional parent relationship when available on the current Flywheel surface.
   - Each hop-selector node must record: the `k` considered option nodes, the selection criterion used, and the chosen continuation.
8. Commit after the node snapshot is coherent with `flywheel_commit_node` (MCP) or `flywheel nodes:commit` (CLI).
   - Commit resolved nodes once `content`, `summary`, artifacts, tags, executions, and graph edges make the snapshot coherent.
   - Keep unresolved plan nodes durable and explicitly unresolved in their content; do not rely on uncommitted local drafts to preserve the frontier.

## Result Contract

When the skill completes a pass, it should leave behind:

- One persisted control node containing the canonical planning contract.
- A single persisted next-step chain up to the current `n` limit where each hop has a selector node plus up to `k` explicit option nodes and one selected continuation.
- Updated node summaries, rationale, and selected edges that make the chosen path explicit without turning the graph into `k` parallel continuation chains.
- No hidden execution, no compute approval, and no managed compute acquisition.

## Persisted Control Contract

Use a dedicated node as the durable planning controller for the current frontier. Do not rely on unstated product fields or fresh chat context.

For the canonical entity model and public contract terminology behind this controller, load [references/INTERFACES.md](references/INTERFACES.md).

Use this storage convention:

1. Reuse an existing control node when one already governs the same frontier; otherwise create one with `flywheel_commit_new_node` or `flywheel_branch_node` (MCP), or `flywheel nodes:commit-new` or `flywheel nodes:branch` (CLI), depending on whether it should attach to an existing parent.
2. Put the canonical contract in node `content`.
3. Put a one-line synopsis in `summary`.
4. Put the planning rationale or branch-selection logic in `content`.
5. Update the control node with `flywheel_acquire_stage_lease` + `flywheel_commit_node` (MCP) or `flywheel nodes:stage:lease:acquire` + `flywheel nodes:commit` (CLI).
6. Read the control node with `flywheel_get_node` (MCP) or `flywheel nodes:get` (CLI) before later replans that need a fresh `expected_revision`.
7. Commit the control node with `flywheel_commit_node` (MCP) or `flywheel nodes:commit` (CLI) once the contract is coherent, even if downstream frontier nodes remain staged.

Canonical contract shape:

```md
## Planning contract

- Objective:
- Decision criterion:
- Start nodes:
- Lookahead depth:
- Step option width:
- Terminal condition:
- Budget ceiling: optional
- Budget unit: optional
```

The `Start nodes` line is the recovery anchor for later replans. If multiple frontier nodes are in scope, list the governing node ids or slugs explicitly.

## Guardrails

- Build the graph explicitly with nodes, artifacts, and selected edges. Do not substitute prose-only option lists for durable option nodes when those options are stable enough to plan against.
- Use the current public Flywheel MCP mutation surface (`flywheel_commit_new_node`, `flywheel_branch_node`, `flywheel_acquire_stage_lease`, `flywheel_commit_node`, `flywheel_add_parent`) rather than inventing local stage-helper tool names.
- Do not request compute approval, acquire managed compute, or launch execution just to do planning.
- These planning-only execution prohibitions apply only when $flywheel-lookahead is the active skill.

See also: invoke `$flywheel-to-graph` to port source material into Flywheel without implicit execution, invoke `$flywheel-reproduce` to graphify claim-bearing sources and run budgeted validation branches, and invoke `$flywheel-auto` to advance a frontier autonomously under an explicit budget and persisted stop condition.
