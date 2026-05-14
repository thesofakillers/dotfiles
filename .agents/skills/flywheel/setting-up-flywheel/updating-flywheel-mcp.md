# How to Update Flywheel MCP

For most users, reinstall / cleanup is:

```bash
npx --yes @paradigma-inc/flywheel uninstall
npx --yes @paradigma-inc/flywheel setup --mode mcp
```

`uninstall` removes Flywheel MCP entries from host config files.

If you choose to refresh via `skills experimental_sync` instead of rerunning
setup, install Flywheel locally in that project first:

```bash
npm install --save-dev @paradigma-inc/flywheel@latest
npx skills experimental_sync --agent codex -y
```

## FAQ: How Do I Migrate from the Previous OAuth-Based MCP Client Setup?

If you installed Flywheel MCP before April 2026, migrate to the newer, more stable API key authentication setup with:

```bash
npx --yes @paradigma-inc/flywheel uninstall
npx --yes @paradigma-inc/flywheel setup --mode mcp
```

If your previous install used a server name different from `flywheel`, pass `--name <old-name>` to uninstall that specific entry.
