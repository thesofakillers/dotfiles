# Installing on Claude Code

Use the setup wizard:

```bash
npx --yes @paradigma-inc/flywheel setup --mode mcp --claude
```

If you installed Flywheel MCP before April 2026, migrate to the newer, more stable API key authentication setup with:

```bash
npx --yes @paradigma-inc/flywheel uninstall --claude
npx --yes @paradigma-inc/flywheel setup --mode mcp --claude
```

If your previous install used a server name different from `flywheel`, pass `--name <old-name>` to uninstall that specific entry.
