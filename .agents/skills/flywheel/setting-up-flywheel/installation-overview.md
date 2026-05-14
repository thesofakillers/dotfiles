# Setting up Flywheel

We are in the business of automating science. As such, our first interface to Flywheel is through autonomous agents, specifically via the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/docs/getting-started/intro).

MCP enables you to natively connect and authenticate Flywheel to any compatible hosts. We recommend using Flywheel with [Codex](https://github.com/openai/codex) or [Claude code](https://github.com/anthropics/claude-code), but any MCP host should work.

## One-command setup (recommended)

Simply run:

```bash
npx --yes @paradigma-inc/flywheel setup --mode mcp
```

`--mode mcp` wires the Flywheel MCP server into the selected hosts and installs
the bundled Flywheel skills. In an interactive terminal, setup can prompt for a
mode; in non-interactive shells, pass `--mode mcp` or `--mode cli` explicitly.
To install the skills without writing any MCP host config, run
`npx --yes @paradigma-inc/flywheel setup --mode cli --install-skill` instead.

If the user is on a remote shell (for example SSH'd into a server), loopback
callback URLs resolve on the wrong machine. Use device auth instead:

```bash
npx --yes @paradigma-inc/flywheel setup --mode mcp --auth-mode device
```

`--auth-mode device` prints a Flywheel device-auth URL and a short setup code;
the user approves in a browser and the CLI polls until the API key is issued.

## Reinstall / cleanup

```bash
npx --yes @paradigma-inc/flywheel uninstall
npx --yes @paradigma-inc/flywheel setup --mode mcp
```

`uninstall` removes Flywheel MCP entries from host config files.

## Web connector hosts (ChatGPT.com / Claude.ai / etc. )

Web connector hosts can still use OAuth-style connector flows. Keep using those host-native connector install UIs for ChatGPT.com custom apps, Claude.ai custom connectors, etc. Simply put `https://flywheel.paradigma.inc/mcp-server` as the URL when prompted.
