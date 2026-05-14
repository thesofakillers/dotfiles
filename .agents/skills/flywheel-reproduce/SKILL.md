---
name: flywheel-reproduce
description: Graphify claim-bearing source material in Flywheel with Flywheel MCP and validate it empirically within a hard maximum budget. Use for reproduction, replication, or claim validation, not planning-only lookahead, source-to-graph authoring without validation, or autonomous frontier expansion.
---

# flywheel-reproduce

## When To Use

Use this skill when the task is to shape information inside Flywheel rather than only discuss it. Use the flywheel-reproduce skill when the source is claim-bearing and the user wants Flywheel to both structure the source and run empirical validation. Flywheel MCP is a node-first durable system of record for research work: nodes hold durable state, artifacts hold supporting files, executions record runs, and compute leases provide managed hardware. Conceptually, the flywheel-reproduce skill is `$flywheel-to-graph` plus budgeted empirical execution: graphify the source first, split it into explicit validation branches, then execute those branches within a hard maximum budget.

If exact tool or field semantics are unclear, load [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md) and [references/INTERFACES.md](references/INTERFACES.md) before mutating nodes or acquiring compute.

## Modes

This skill supports both Flywheel install modes:

- **`--mode mcp` install**: route via [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md); tool calls take the form `flywheel_<tool>` (e.g., `flywheel_commit_node`).
- **`--mode cli` install**: `setup --mode cli` configures runtime credentials, then route via [references/flywheel-cli-tool-map.md](references/flywheel-cli-tool-map.md); tool calls take the form `flywheel <command>` (e.g., `flywheel nodes:commit`). Prerequisite for bare-binary routing: run the curl installer with `--mode cli` or use the managed-prefix npm install recipe from the README.

When switching an already-configured host between modes, rerun setup with `--force` (or uninstall first) so prior-mode artifacts are reconciled explicitly.

The Workflow below cites both the MCP tool name and its CLI equivalent inline at each imperative step. Pick the one matching your install mode.

## Input Contract

Before execution, recover or establish these inputs:

- Required before execution: claim-bearing source material or existing claim nodes, a measurable objective, a hard max budget, and an explicit stopping criterion.
- Optional: preferred validation branch types, execution constraints, and source-format hints.
- Recovery rules:
  - Ask only when a required execution input cannot be recovered from explicit user instructions, current conversational context, or recent graph state.
  - If the source is already structured in Flywheel, recover the governing source or claim nodes from graph state before asking.
  - If the objective is missing, ask once; if the user refuses, infer an objective such as validating the central claims within the available budget and persist it before execution.
  - If the hard max budget is missing, ask once before execution. Until the budget is explicit, graph construction and branch planning may proceed, but empirical execution must not start.
  - If the stopping criterion is missing, ask once; if it remains unspecified, persist a criterion such as stopping when the core claim is resolved or the budget ceiling is reached.

## Working Terms

- `claim-bearing source`: source material that contains concrete empirical claims worth validating or refuting.
- `validation branch`: an explicit node or subtree that tests one claim, mechanism, baseline, robustness property, or failure mode.
- `hard max budget`: a non-negotiable spend ceiling that empirical execution must not exceed.
- `normalized Flywheel graph export`: already-structured Flywheel node JSON with DAG-safe edges, suitable for `flywheel_import_subgraph`.
- `expected_revision`: the node's current revision token used for optimistic-locking writes.

## Core Rules

- Prefer explicit Flywheel node and artifact operations over ad hoc bulk-import stories, because node-first authoring keeps the graph legible and auditable.
- Treat the main page body as the node readme/body field (`content` on modern Flywheel surfaces).
- Use artifacts for supporting files and evidence, not as a substitute for the node's main narrative, because the node body should remain the readable source-of-truth for the claim and validation story.
- Only create graph edges for durable semantic relationships, because graphifying every wiki link floods the graph with noise that hides decision-relevant structure.
- Use `flywheel_import_subgraph` only for prebuilt Flywheel graph JSON, not for raw markdown repositories, because raw corpora are usually file-centric and cyclic rather than clean node-centric payloads.
- Treat the flywheel-reproduce skill as claim validation, not as a magical importer. It combines graphification with budgeted empirical execution, because claim-bearing work should become explicit validation branches before compute is spent.
- Ask only the minimum clarification questions needed to establish a coherent validation contract, and ask none when the required answers are already recoverable from user instructions, conversational context, or graph state.
- For empirical execution, load [references/experiment-design-protocol.md](references/experiment-design-protocol.md) and [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md) before spending compute.

## Workflow

1. Resolve the starting context.
   - Start from existing knowledge that should be validated, not from an open-ended frontier expansion loop.
   - Resolve source or claim nodes in this order: explicit node ids/slugs, explicitly named current context, focused or recently referenced nodes, then ask the user if nothing stable is recoverable.
2. Resolve the validation contract.
   - Recover required execution inputs from the current conversation and graph first. Ask only for inputs that remain genuinely missing after that recovery pass.
   - The flywheel-reproduce skill requires a measurable objective and a hard max budget. Ask once for missing prerequisites; if the user refuses to specify an objective, infer it from the available graph context and state it explicitly before continuing.
   - Run the design gate from [references/experiment-design-protocol.md](references/experiment-design-protocol.md) before any compute request: confirm objective, decision criterion, evidence plan, branch strategy, and budget readiness.
   - Persist the validation contract in a dedicated control node for this source or claim family. Put the canonical contract and brief validation rationale in node `content`, and keep a one-line synopsis in `summary`.
   - The control contract must name: objective, decision criterion, source or claim nodes under test, budget ceiling and unit, and an explicit stopping criterion.
   - Later reproduce passes must read the control node `content` first and continue from that persisted contract rather than from chat memory.
3. Classify the source.
   - If the input is already a normalized Flywheel graph export, `flywheel_import_subgraph` may be appropriate.
   - Otherwise, route to one source reference in `references/` using the
     `Source Type Routing` section below.
   - Complete source decomposition from the selected reference before step 8
     branch planning or execution.
4. Map each stable page, claim, or concept to a node.
   - For exact node-mutation shapes, load [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md).
   - Create a new node with `flywheel_commit_new_node` (MCP) or `flywheel nodes:commit-new` (CLI) when needed.
   - Update an existing node with `flywheel_get_node` + `flywheel_acquire_stage_lease` + `flywheel_commit_node` (MCP) or `flywheel nodes:get` + `flywheel nodes:stage:lease:acquire` + `flywheel nodes:commit` (CLI) when continuing work.
5. Put the primary page markdown or validation rationale in the node body/readme field (`content`).
   - Keep `summary` concise.
   - Put claims, rationale, methods, outcomes, and continuation notes in `content`; keep `summary` concise.
6. Publish supporting files with the artifact upload flow.
   - For exact artifact contract details, load [references/ARTIFACTS.md](references/ARTIFACTS.md).
   - Use `flywheel_prepare_artifact_uploads` (MCP) or `flywheel artifacts:upload:prepare` (CLI).
   - Upload raw file bytes to the returned signed URLs.
   - Call `flywheel_finalize_artifact_uploads` (MCP) or `flywheel artifacts:upload:finalize` (CLI) once all uploads in the batch are staged.
   - Keep the artifact filename stable enough to reference from markdown when inline rendering matters.
7. Add graph structure sparingly.
   - Promote only decision-relevant relationships to edges.
   - Leave ordinary cross-links inside the markdown body.
8. Plan and execute validation branches against the hard max budget.
   - Prioritize the cheapest branches that most reduce uncertainty first.
   - Prefer explicit validation branches such as baseline checks, mechanism or intermediate-signal checks, ablations, efficiency checks, robustness checks, failure analysis, and follow-up analysis branches after results land.
   - If the branch can run through Flywheel execution directly, use `flywheel_launch_execution` (MCP) or `flywheel executions:launch` (CLI) and inspect terminal status before commit.

   - If the branch needs managed compute, in MCP mode use `flywheel_request_compute_grant_approval`, resolve the approved `compute_grant_id` with `flywheel_list_compute_grants(status=active, approval_session_id=<session_id>)`, call `flywheel_compute_list_options`, recommend one offer deterministically and present up to two alternatives, wait for explicit user confirmation (or explicit user override offer id), then `flywheel_compute_acquire`, poll `flywheel_compute_status`, and use `flywheel_compute_connection` when the lease is ready. In CLI mode use the parallel `flywheel compute-grants:request-approval` → `flywheel compute-grants:list` → `flywheel compute:options` → `flywheel compute:acquire` → `flywheel compute:status` → `flywheel compute:connection` sequence.
   - Release managed compute when a branch is done. Default to releasing only
     known leases. Use release-all with the active `lease_control_token` for
     token-scoped bulk cleanup; add `force=true` (MCP) or `--force --yes` (CLI)
     only when the user explicitly requests account-wide cleanup.
   - Stop when the core claim is resolved or the budget ceiling is reached.

9. Commit after the node snapshot is coherent with `flywheel_commit_node` (MCP) or `flywheel nodes:commit` (CLI).
   - Commit resolved nodes once `content`, `summary`, artifacts, tags, executions, and graph edges make the snapshot coherent.
   - Leave unresolved plan nodes staged.

## Result Contract

When the skill completes a pass, it should leave behind:

- Graphified source nodes or updated claim nodes that preserve the source material legibly in `content`.
- One persisted control node containing the canonical validation contract.
- Zero or more explicit validation branches staged or resolved under the hard max budget.
- Coherent committed nodes, with artifacts attached when evidence exists.
- Released managed compute if any lease was acquired during the pass.

## Persisted Validation Contract

Use a dedicated node as the durable validation controller for the current source or claim family. Do not rely on unstated product fields or fresh chat context.

For the canonical entity model and public contract terminology behind this controller, load [references/INTERFACES.md](references/INTERFACES.md).

Use this storage convention:

1. Reuse an existing control node when one already governs the same source or claim family; otherwise create one with `flywheel_commit_new_node` (MCP) or `flywheel nodes:commit-new` (CLI).
2. Put the canonical contract in node `content`.
3. Put a one-line synopsis in `summary`.
4. Put the validation rationale, branch-priority logic, or continuation rule in `content`.
5. Before committing control-node edits, acquire or refresh the stage lease with `flywheel_acquire_stage_lease` (and `flywheel_heartbeat_stage_lease` for long edits) — or in CLI mode, `flywheel nodes:stage:lease:acquire` and `flywheel nodes:stage:lease:heartbeat`.
6. Read the control node with `flywheel_get_node` (MCP) or `flywheel nodes:get` (CLI) before later passes that need a fresh `expected_revision`.
7. Commit the control node with `flywheel_commit_node` (MCP) or `flywheel nodes:commit` (CLI) once the contract is coherent, even if downstream validation branches remain staged or in progress.

Canonical contract shape:

```md
## Validation contract

- Objective:
- Decision criterion:
- Source or claim nodes under test:
- Budget ceiling:
- Budget unit:
- Stopping criterion:
- Preferred branch types: optional
```

The `Source or claim nodes under test` line is the recovery anchor for later validation passes. If multiple claim nodes are in scope, list the governing node ids or slugs explicitly.

## Source Type Routing

Route every non-normalized source through one reference file before
graphification and validation planning.

Routing order:

1. Deterministic routing.
2. Natural-language routing.
3. Generic fallback.

Deterministic routing rules:

- Local `.pdf` files -> `references/source-paper.md`
- `arxiv.org/abs/*`, `arxiv.org/pdf/*`, DOI URLs, direct PDF URLs -> `references/source-paper.md`
- Markdown files, wiki exports, wiki-like repositories -> `references/source-wiki.md`
- Blog/article domains and long-form article URLs -> `references/source-blog.md`
- Local notes trees (Obsidian, Logseq, plain markdown note directories) -> `references/source-notes.md`

Natural-language routing rule:

- If deterministic routing is inconclusive, use user intent from prompt/context
  (for example, "import this paper", "graph this wiki", "convert this blog
  post", "port these research notes") and pick the matching source reference.

Generic fallback rule:

- If deterministic and natural-language routing are both inconclusive, load
  `references/source-generic.md`.

After choosing a source type, load that reference and complete source
decomposition before entering step 8 validation branch planning.

## `flywheel_import_subgraph`

Use `flywheel_import_subgraph` only when the input is already normalized into Flywheel node JSON with DAG-safe edges.

Do not use it for raw markdown repositories because those are usually:

- file-centric rather than node-centric
- heavily cross-linked
- cyclic in ways that are natural for a wiki but not a clean Flywheel graph

Treat raw wiki content as authoring input, not as a direct subgraph payload.

## Edge Policy

Promote a relation to a graph edge only when it carries durable meaning such as:

- hierarchy or decomposition
- prerequisite or dependency
- derived-from or result-of
- canonical comparison target

Do not create edges for every incidental mention, backlink, or navigational cross-reference. Keep those inside the markdown body instead.

## Inline Artifact Embeds

When the node body supports inline artifact rendering, keep references on their own lines so the renderer can replace them with the matching artifact preview.

Examples:

```md
![Loss curve](loss-curve.png)

[Evaluation metrics](metrics.json)
```

Guidelines:

- Upload the artifact first, then reference it from the body.
- Keep filenames stable enough for the renderer to match them.
- Use inline embeds for supporting visuals or data, but keep the main explanation in the node body itself.
- If a reference does not match an artifact, it should remain valid markdown rather than break the page.

## Guardrails

- Do not treat the flywheel-reproduce skill as a magical bulk importer.
- Do not blur `$flywheel-reproduce` and `$flywheel-auto`, because `$flywheel-reproduce` validates existing knowledge claims while `$flywheel-auto` expands a frontier autonomously under budget.
- Build the graph explicitly with nodes, artifacts, and selected edges.
- Keep the source material legible in `content`; do not dump everything into artifacts.
- Keep the flywheel-reproduce skill scoped by cost and decision value, not by exhaustively trying every possible branch.
- These claim-validation execution rules apply only when $flywheel-reproduce is the active skill.

See also: invoke `$flywheel-to-graph` to port source material into Flywheel without implicit execution, invoke `$flywheel-lookahead` to stage next-step frontier nodes from existing graph state without execution, and invoke `$flywheel-auto` to advance a frontier autonomously under an explicit budget and persisted stop condition.
