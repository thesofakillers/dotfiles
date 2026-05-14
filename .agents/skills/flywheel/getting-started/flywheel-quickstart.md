# Welcome to Flywheel

Install Flywheel in your MCP host with:

```bash
npx --yes @paradigma-inc/flywheel setup --mode mcp
```

If you installed Flywheel MCP before April 2026, migrate to the newer, more stable API key authentication setup with:

```bash
npx --yes @paradigma-inc/flywheel uninstall
npx --yes @paradigma-inc/flywheel setup --mode mcp
```

If your previous install used a server name different from `flywheel`, pass `--name <old-name>` to uninstall that specific entry.

If your MCP host is not supported by `npx --yes @paradigma-inc/flywheel setup --mode mcp`, use manual host configuration:

- URL: `https://flywheel.paradigma.inc/mcp-server`
- Header: `Authorization: Bearer <YOUR_MCP_API_KEY>`

For hosts that support MCP OAuth connector installs, you can also use the host-native OAuth connector flow with `https://flywheel.paradigma.inc/mcp-server`.
