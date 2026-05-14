# Other MCP hosts

If your host is not currently supported by `npx --yes @paradigma-inc/flywheel setup --mode mcp`, you can still connect manually.

1. In the Flywheel WebUI, open **Settings**, go to the **User** tab, expand **MCP API keys**, and click **Create key**.
2. Copy the key immediately (it is shown once).
3. Add a Flywheel MCP server entry in your host config with:
   - URL: `https://flywheel.paradigma.inc/mcp-server`
   - Header: `Authorization: Bearer <YOUR_MCP_API_KEY>`

Example JSON-style host config:

```json
{
  "mcpServers": {
    "flywheel": {
      "type": "http",
      "url": "https://flywheel.paradigma.inc/mcp-server",
      "headers": {
        "Authorization": "Bearer <YOUR_MCP_API_KEY>"
      }
    }
  }
}
```

Example TOML-style host config:

```toml
[mcp_servers.flywheel]
type = "http"
url = "https://flywheel.paradigma.inc/mcp-server"

[mcp_servers.flywheel.headers]
Authorization = "Bearer <YOUR_MCP_API_KEY>"
```

Different hosts use different field names (`mcpServers`, `mcp_servers`, `mcp.servers`, etc.), but the server URL and `Authorization` bearer header are the key pieces.

Alternative: for any host that supports MCP OAuth, you can use its OAuth connector install flow and set the MCP URL to `https://flywheel.paradigma.inc/mcp-server`. Web connector hosts (for example ChatGPT.com, Claude.ai) commonly use this path. It can be convenient, but it may prompt re-authorization more often than the API key route depending on the host token lifecycle and refresh behavior.
