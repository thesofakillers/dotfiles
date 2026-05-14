# Flywheel Tree Workflow

Follow this workflow exactly.

## 1. Resolve Selector In Agent

Infer the best selector string from the user request (node id or slug).

- If selector is explicit in user text, use it directly.
- If selector is implicit but inferable, extract it.
- If no selector is provided, infer from user wording.
- If inference is not possible, ask one concise question for the root id or slug.

## 2. Run One Wrapper Command (No JSON Marshalling)

Do not call `flywheel_get_node_tree` in the agent and then re-emit large JSON.
Run `scripts/render_tree_via_mcp.py`, which calls MCP tools and renders in-process.

```bash
# Ubuntu/macOS (bash/zsh)
SKILL_ROOT=""
for CANDIDATE in \
  "$(pwd)/.agents/skills/flywheel-tree" \
  "$HOME/.agents/skills/flywheel-tree" \
  "$HOME/.codex/skills/flywheel-tree" \
  "${CODEX_HOME:+$CODEX_HOME/skills/flywheel-tree}"; do
  if [ -n "$CANDIDATE" ] && [ -f "$CANDIDATE/scripts/render_tree_via_mcp.py" ]; then
    SKILL_ROOT="$CANDIDATE"
    break
  fi
done
if [ -z "$SKILL_ROOT" ]; then
  echo "flywheel-tree skill not found" >&2
  exit 2
fi
# No repository checkout is required.
uv run --quiet --with mcp python \
  "$SKILL_ROOT/scripts/render_tree_via_mcp.py" \
  --selector "<node-id-or-slug>" \
  --projection topology \
  --max-nodes 1000
```

```powershell
# Windows (PowerShell)
$candidates = @(
  (Join-Path (Get-Location).Path ".agents/skills/flywheel-tree"),
  (Join-Path $HOME ".agents/skills/flywheel-tree"),
  (Join-Path $HOME ".codex/skills/flywheel-tree")
)
if ($env:CODEX_HOME) {
  $candidates += (Join-Path $env:CODEX_HOME "skills/flywheel-tree")
}
$skillRoot = $null
foreach ($candidate in $candidates) {
  if (Test-Path (Join-Path $candidate "scripts/render_tree_via_mcp.py")) {
    $skillRoot = $candidate
    break
  }
}
if (-not $skillRoot) {
  throw "flywheel-tree skill not found"
}
# No repository checkout is required.
uv run --quiet --with mcp python `
  "$skillRoot/scripts/render_tree_via_mcp.py" `
  --selector "<node-id-or-slug>" `
  --projection topology `
  --max-nodes 1000
```

MCP endpoint and credentials source:

- Config is auto-discovered in this order:
  - `--codex-config <path>` or `--mcp-config <path>` when provided
  - `CODEX_CONFIG` env var
  - `CODEX_HOME/config.toml`
  - nearest `./.codex/config.toml` (walking parent directories)
  - `~/.codex/config.toml`
  - nearest `./.mcp.json` (walking parent directories)
  - `~/.claude.json`
- MCP alias default is `flywheel`. If that alias is missing, the wrapper auto-selects a compatible `flywheel*` alias.
- Use `--codex-mcp-server` to force a specific alias.
- Use `--mcp-url` / `--access-token` only for explicit overrides.

Do not edit the graph.

## 3. Print Renderer Output As-Is

Preserve renderer stdout exactly. Do not rewrite formatting.

- In chat responses, present the tree inside a fenced `text` code block.
- Preserve all leading indentation spaces and box-drawing characters.

Expected output format:

- Terminal tree with box-drawing characters
- Node label format: `name | slugname` when slug exists, otherwise `name`
- Duplicate views for multi-parent nodes
- One unique color per multi-parent set
- `slugname` segment is always gray
- Summary with exactly:
  - `root: <title>`
  - `node_count: <count>`
