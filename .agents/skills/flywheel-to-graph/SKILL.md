---
name: flywheel-to-graph
description: Port source material into Flywheel nodes, artifacts, and durable edges with Flywheel MCP, without execution or compute spend. Use for source-to-graph authoring, not empirical validation, next-step planning, or autonomous execution.
---

# flywheel-to-graph

## When To Use

Use this skill when the task is to shape information inside Flywheel rather than only discuss it. Use the flywheel-to-graph skill when the user's main goal is to convert unstructured source material into a Flywheel graph. Flywheel MCP is a node-first durable system of record for research work: nodes hold durable state, artifacts hold supporting files, executions record runs, and compute leases provide managed hardware. This skill is authoring only: it ports source material into nodes, artifacts, and durable edges without hidden execution, compute approval, or managed compute acquisition.

If exact tool or field semantics are unclear, load [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md) and [references/INTERFACES.md](references/INTERFACES.md) before mutating nodes.

## Modes

This skill supports both Flywheel install modes:

- **`--mode mcp` install**: route via [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md); tool calls take the form `flywheel_<tool>` (e.g., `flywheel_commit_node`).
- **`--mode cli` install**: `setup --mode cli` configures runtime credentials, then route via [references/flywheel-cli-tool-map.md](references/flywheel-cli-tool-map.md); tool calls take the form `flywheel <command>` (e.g., `flywheel nodes:commit`). Prerequisite for bare-binary routing: run the curl installer with `--mode cli` or use the managed-prefix npm install recipe from the README.

When switching an already-configured host between modes, rerun setup with `--force` (or uninstall first) so prior-mode artifacts are reconciled explicitly.

The Workflow below cites both the MCP tool name and its CLI equivalent inline at each imperative step. Pick the one matching your install mode.

## Input Contract

Before authoring, recover or establish these inputs:

- Required before authoring: source material or explicit source nodes, and the intended source-to-graph scope.
- Optional: preferred root node, subtree shape, node granularity, and whether budget metadata should be tracked for later execution-oriented work.
- Recovery rules:
  - Ask only when the source corpus, source nodes, or intended scope cannot be recovered from explicit user instructions, current conversational context, or recent graph state.
  - If the corpus is already represented in Flywheel, recover the governing source nodes before asking.
  - If no explicit scope is given, infer the narrowest stable scope that matches the provided source material and state it before authoring.

## Working Terms

- `source corpus`: the input material to port, such as papers, blog posts, READMEs, markdown wikis, or research notes.
- `normalized Flywheel graph export`: already-structured Flywheel node JSON with DAG-safe edges, suitable for `flywheel_import_subgraph`.
- `durable edge`: a graph relationship that carries stable semantic meaning, not just a navigational hyperlink.
- `authoring pass`: one pass that reads source material and stages or commits the corresponding node/artifact updates.
- `graph-native import`: an import that preserves the source's substantive ideas, procedures, evidence, and durable relationships in a graph-friendly form, without needing to mirror the original prose order, headings, or layout.
- `expected_revision`: the node's current revision token used for optimistic-locking writes.

## Core Rules

- Prefer explicit Flywheel node and artifact operations over ad hoc bulk-import stories, because node-first authoring keeps the graph legible and auditable.
- Treat the main page body as the node readme/body field (`content` on modern Flywheel surfaces).
- Favor graph-native imports over format-mirroring summaries, because the graph should preserve the source's logic and concepts rather than its table of contents.
- Use source headings, file boundaries, page order, and layout as hints, not obligations.
- Prefer nodes for stable concepts, claims, entities, procedures, datasets, baselines, results, comparisons, decisions, and dependencies, because those survive format changes better than section labels.
- If a page or section is too dense for one node to remain legible and information-complete, split it into more nodes rather than dropping detail.
- Preserve reusable specifics in node `content`, such as definitions, assumptions, procedures, commands, equations, parameters, datasets, metrics, results, examples, and caveats when present in the source.
- Default to paraphrased or synthesized node content. Preserve verbatim wording only when exact phrasing is itself important, such as commands, equations, error strings, definitions, prompts, contractual language, or exact claims.
- Use artifacts for supporting files and evidence, not as a substitute for the node's main narrative, because the node body should remain the readable source-of-truth for the imported material.
- Only create graph edges for durable semantic relationships, because graphifying every wiki link floods the graph with noise that hides decision-relevant structure.
- Use `flywheel_import_subgraph` only for prebuilt Flywheel graph JSON, not for raw markdown repositories, because raw corpora are usually file-centric and cyclic rather than clean node-centric payloads.
- Treat the flywheel-to-graph skill as source-to-graph authoring only. It ports material into Flywheel primitives but does not execute branches or spend budget implicitly, because that changes the job into `$flywheel-reproduce` or `$flywheel-auto`.

## Concept-First Standard

Graphify the source so a reader or model can recover the material's ideas and durable relationships from the graph, even if the graph no longer mirrors the source's original order, headings, or prose.

This means:

- Organize around concepts, claims, procedures, entities, results, comparisons, and dependencies.
- Keep actual substance, not just headings or section labels.
- Preserve key facts, procedures, evidence, caveats, and examples.
- Increase node granularity when needed instead of compressing dense sections into shallow blurbs.
- Paraphrase and synthesize by default instead of repeating source wording verbatim.
- Keep exact wording only when the wording itself matters.
- Let the graph diverge from the source format when that produces a clearer conceptual structure.
- Use artifacts to keep the raw original and bulky supporting material, but do not rely on artifacts alone for essential explanation.

## Workflow

1. Resolve the starting context.
   - Start from the provided source material or explicit source nodes.
   - Resolve governing nodes in this order: explicit node ids/slugs, explicitly named current context, focused or recently referenced nodes, then ask the user if nothing stable is recoverable.
2. Classify the input through source-type routing.
   - If it is already a normalized Flywheel graph export, `flywheel_import_subgraph` may be appropriate.
   - Otherwise, route to one source reference in `references/` using the `Source Type Routing` section below.
   - Complete source routing before step 3 node mapping.
3. Map each stable page, claim, or concept to a node.
   - For exact node-mutation shapes, load [references/flywheel-mcp-tool-map.md](references/flywheel-mcp-tool-map.md).
   - Choose node boundaries by conceptual cohesion and durable relationships first, then use file or heading boundaries as secondary hints.
   - Create a new node with `flywheel_commit_new_node` (MCP) or `flywheel nodes:commit-new` (CLI) when needed.
   - Update an existing node with `flywheel_get_node` + `flywheel_acquire_stage_lease` + `flywheel_commit_node` (MCP) or `flywheel nodes:get` + `flywheel nodes:stage:lease:acquire` + `flywheel nodes:commit` (CLI) when continuing work.
   - If the source layout hides the real structure, regroup material into concept, procedure, claim, dataset, baseline, result, comparison, decision, or dependency nodes.
   - If a section would become a shallow stub, split it into more graph-native nodes until the imported graph preserves the underlying logic.
4. Put a graph-native narrative in the node body/readme field (`content`).
   - Write `content` so another reader or model can recover the unit's meaning and role in the graph without needing the original prose order.
   - Put claims, rationale, methods, outcomes, continuation notes, and source-supported caveats in `content`; keep `summary` concise.
   - Populate `hypothesis`, `insights`, `outcome`, and similar fields only when the source actually supports them.
   - Preserve definitions, procedures, arguments, commands, equations, configs, datasets, metrics, results, examples, and caveats when present.
   - Prefer paraphrase and synthesis over copy-paste transcription.
   - Do not stop at "this section describes X"; include what X actually says and how it connects to neighboring nodes.
5. Publish supporting files with the artifact upload flow.
   - For exact artifact contract details, load [references/ARTIFACTS.md](references/ARTIFACTS.md).
   - Use `flywheel_prepare_artifact_uploads` (MCP) or `flywheel artifacts:upload:prepare` (CLI).
   - Upload raw file bytes to the returned signed URLs.
   - Call `flywheel_finalize_artifact_uploads` (MCP) or `flywheel artifacts:upload:finalize` (CLI) once all uploads in the batch are staged.
   - Keep the artifact filename stable enough to reference from markdown when inline rendering matters.
6. Add graph structure sparingly.
   - Promote only durable semantic relationships to edges.
   - Prefer relationships such as defines, depends-on, compares-with, evaluates, produces, supports, contradicts, decomposes-into, or derived-from when the source supports them.
   - Leave ordinary cross-links inside the markdown body.
7. Commit after the node snapshot is coherent with `flywheel_commit_node` (MCP) or `flywheel nodes:commit` (CLI).
   - Commit once the source narrative, artifact attachments, and selected graph structure agree with each other.

## Result Contract

When the skill completes a pass, it should leave behind:

- A root node or subtree that represents the source material in Flywheel.
- The primary narrative preserved in graph-native node `content`.
- The imported graph organized around the material's conceptual and logical structure, even when that differs from the source's original format or prose order.
- Supporting files attached as artifacts where appropriate.
- Only durable graph edges added to the graph.
- No hidden execution, no compute approval, and no managed compute acquisition.

## Persisted Authoring Contract

When the source-to-graph work spans multiple pages or multiple passes, use a dedicated node as the durable authoring controller for that corpus. Do not rely on unstated product fields or fresh chat context.

For the canonical entity model and public contract terminology behind this controller, load [references/INTERFACES.md](references/INTERFACES.md).

Use this storage convention:

1. Reuse an existing authoring control node when one already governs the same corpus; otherwise create one with `flywheel_commit_new_node` (MCP) or `flywheel nodes:commit-new` (CLI).
2. Put the canonical authoring contract in node `content`.
3. Put a one-line synopsis in `summary`.
4. Put the current mapping rationale or continuation note in `content`.
5. Before committing control-node edits, acquire or refresh the stage lease with `flywheel_acquire_stage_lease` (and `flywheel_heartbeat_stage_lease` for long edits) — or in CLI mode, `flywheel nodes:stage:lease:acquire` and `flywheel nodes:stage:lease:heartbeat`.
6. Read the control node with `flywheel_get_node` (MCP) or `flywheel nodes:get` (CLI) before later passes that need a fresh `expected_revision`.
7. Commit the control node with `flywheel_commit_node` (MCP) or `flywheel nodes:commit` (CLI) once the contract is coherent, even if downstream source nodes remain staged or in progress.

Canonical contract shape:

```md
## Authoring contract

- Source corpus:
- Intended scope:
- Root node or subtree target:
- Default node granularity:
- Edge policy:
- Execution policy:
```

The `Source corpus` and `Intended scope` lines are the recovery anchors for later authoring passes.

## Source Type Routing

Route every non-normalized source through one reference file before authoring.

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

After choosing a source type, load that reference and follow its acquisition,
parsing, decomposition, artifact, and failure contracts for the rest of the
authoring pass.

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

- Do not hide spend behind the flywheel-to-graph skill.
- Build the graph explicitly with nodes, artifacts, and selected edges.
- Keep the source material legible in `content`; do not dump everything into artifacts.
- Do not mirror the source's table of contents, file tree, or presentation order mechanically when a concept-first graph is clearer.
- Do not turn source-to-graph import into verbatim transcription; paraphrase unless exact wording matters.
- Do not confuse graphifying the source with empirically validating it: preserve enough detail for later reuse, but do not execute or test claims inside `$flywheel-to-graph`.
- These source-to-graph authoring-only rules apply only when $flywheel-to-graph is the active skill.

See also: invoke `$flywheel-reproduce` to graphify claim-bearing sources and run budgeted validation branches, invoke `$flywheel-lookahead` to stage next-step frontier nodes from existing graph state without execution, and invoke `$flywheel-auto` to advance a frontier autonomously under an explicit budget and persisted stop condition.
