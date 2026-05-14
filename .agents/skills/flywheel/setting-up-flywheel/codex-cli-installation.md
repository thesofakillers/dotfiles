# Installing on Codex

Use the setup wizard:

```bash
npx --yes @paradigma-inc/flywheel setup --mode mcp --codex
```

If you installed Flywheel MCP before April 2026, migrate to the newer, more stable API key authentication setup with:

```bash
npx --yes @paradigma-inc/flywheel uninstall --codex
npx --yes @paradigma-inc/flywheel setup --mode mcp --codex
```

If your previous install used a server name different from `flywheel`, pass `--name <old-name>` to uninstall that specific entry.
