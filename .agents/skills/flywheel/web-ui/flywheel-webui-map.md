# Flywheel Web UI Map

Use this map when a user asks where to find a feature in the web interface.

## Primary Areas

- Graph canvas: browse nodes, branches, and topology for the current workspace.
- Node panel: inspect node metadata, Markdown content, summaries, artifacts, tags, executions, and access state.
- Artifact views: open uploaded artifacts (plots, tables, JSON, text, HTML).
- Search and filters: narrow nodes by title, content, state, and tags.
- Access and sharing controls: review and update visibility/collaboration policy.
- Settings: account-level preferences, machines/leases, and credit-related pages.

## Navigation Tips

- If the user is trying to create or mutate nodes, route them to MCP tools first;
  treat Web UI as visibility and inspection by default.
- If the user reports a graph mismatch, cross-check node state through MCP reads
  (`list_nodes`, `get_node`, `get_node_tree`) before assuming UI-only issues.
- If the user asks about compute cost or lease lifecycle, direct to Settings
  machine and credit views plus `compute/*` references.

## Pairing With Other Docs

- Start with `web-ui/the-flywheel-web-ui.md` for overview behavior.
- Use `references/flywheel-mcp-tool-map.md` when the answer depends on exact MCP
  tool capabilities or runtime contract.
