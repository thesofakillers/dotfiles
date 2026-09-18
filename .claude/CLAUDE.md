@~/.codex/AGENTS.md

# Connectors and MCP servers

Never tell me a connector or capability is unavailable until you have actually tried to use it.

Capabilities are duplicated here. An unauthenticated plugin server and a working claude.ai connector
routinely share a name: `plugin:linear:linear` and `plugin:slack:slack` are inline plugins pointing at
each vendor's own MCP endpoint, are permanently `needs_auth`, and have never been used — while the
`Linear` and `Slack` connectors are authorized and work. A `needs_auth` line in the system prompt
therefore says nothing about whether the capability is reachable.

Before reporting a connector as unusable:

1. Call `session_connectors_status` and look for a *connected* server offering the same capability
   under a different name or id.
2. If the one you need shows `failed`, call `reconnect_session_connector`, end the turn, and check again.
3. Only if there is no connected equivalent, say so — and name the specific server that needs auth,
   not the capability. "Linear is unavailable" is wrong when the Linear connector is serving 74 tools.

Retry once before concluding anything. Two known upstream bugs make a single failure weak evidence:
claude.ai connectors drop as a group mid-session and silently return a few turns later
(anthropics/claude-code#86080), and a failed connect is negative-cached for ~15 minutes, which can make
a whole session believe tools are missing when they are not (#90844).
