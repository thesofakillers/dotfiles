---
name: flywheel-tree
description: Render Flywheel DAGs as terminal tree views.
---

# Flywheel Tree

## When To Use

Use this skill when the user wants a Flywheel graph shown in classical CLI tree format from a node id or slug.
Use it to inspect structure, compare branch topology, or audit parent-child relationships in read-only mode.
Always print the descendant subgraph rooted at the user-provided node; print the full DAG only when that provided node is the actual DAG root.
This skill uses one local wrapper command (selector -> MCP resolve/get_node_tree -> in-process render) to keep output deterministic and latency low.

## Modes

This skill supports both Flywheel install modes, with an MCP-first execution path:

- **`--mode mcp` install**: preferred for this skill because `scripts/render_tree_via_mcp.py` resolves and calls MCP directly.
- **`--mode cli` install**: `setup --mode cli` configures runtime credentials for CLI routing; prerequisite for bare-binary routing is the curl installer with `--mode cli` or the managed-prefix npm install recipe from the README. This skill's wrapper still reads through MCP, so keep MCP wiring available for the host that runs the script.

When switching an already-configured host between modes, rerun setup with `--force` (or uninstall first) so prior-mode artifacts are reconciled explicitly.

## Input Contract

Accept any of these as the root selector:

- Node id (UUID-like string)
- Slug name (for example `quiet-snow-3839`)
- Natural-language root reference in the user message (for example "DAG whose root is quiet-snow-3839")

If no node id or slug is explicitly provided:

- Infer the root from user wording.
- If inference is not possible, ask one concise question requesting the root id or slug.

## Workflow

1. Follow [workflow.md](references/workflow.md) end-to-end.
2. Use `scripts/render_tree_via_mcp.py` as the only execution path:
   - The script resolves slug selectors via `flywheel_resolve_node_slug` when needed.
   - The script fetches topology via `flywheel_get_node_tree`.
   - The script renders in-process with `render_tree.py`.
   - Run it via `uv run --quiet --with mcp python ...` so the skill does not depend on any repository layout and keeps stdout clean.
   - The script auto-discovers MCP config from `--codex-config`/`--mcp-config`, `CODEX_CONFIG`, `CODEX_HOME/config.toml`, nearest project `.codex/config.toml`, `~/.codex/config.toml`, nearest project `.mcp.json`, then `~/.claude.json`, and tries candidates until one resolves the requested alias.
   - Default MCP alias is `flywheel`; when missing, the script auto-resolves a compatible `flywheel*` alias.
   - Do not pipe full tree JSON through shell here-strings.
   - Do not write temporary JSON files.
3. Preserve renderer output formatting exactly:
   - In chat responses, wrap renderer stdout in a fenced `text` code block.
   - Do not alter indentation or rewrite line prefixes.
4. Keep visual conventions produced by the renderer:
   - Node label: `name | slugname` when slug exists.
   - Omit `| slugname` entirely when slug is missing.
   - `slugname` is always gray.

## Result Contract

- Do not edit the graph.
- Use read-only analysis only.
- Do not mutate nodes, tags, artifacts, parents, sharing, or executions.
- If data retrieval or script execution fails, report the failure reason and stop.

## Resources

- `scripts/render_tree.py`: deterministic tree renderer for raw `flywheel_get_node_tree` JSON.
- `scripts/render_tree_via_mcp.py`: one-command MCP wrapper (resolve selector -> get tree -> render).
- `references/workflow.md`: full operational workflow and invocation commands.
- `assets/ansi_palette.json`: color palette used by the renderer.
