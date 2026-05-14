# FAQ: How Can I Get an Authorized `client_id` for the OAuth Flow?

We support the standard MCP OAuth flow with dynamic client registration, as documented in the [MCP Authorization spec (dynamic client registration)](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization#dynamic-client-registration).

First, query our OAuth authorization-server metadata:

```bash
curl -sS https://flywheel.paradigma.inc/mcp-server/.well-known/oauth-authorization-server | jq
```

That response includes the OAuth endpoints (`authorization_endpoint`, `token_endpoint`, `registration_endpoint`, and others).

`response_types_supported` is currently `["code"]`, so register with `"response_types":["code"]`.

Then register your OAuth client using the `registration_endpoint`.

## Public client (default)

This is the default for interactive MCP hosts (for example Claude Code, IDE hosts, local desktop clients). If `token_endpoint_auth_method` is omitted, we default to `none`.

```bash
curl -sS -X POST https://flywheel.paradigma.inc/mcp-server/register \
  -H "content-type: application/json" \
  -d '{
    "client_name":"Flywheel MCP Host",
    "redirect_uris":["http://localhost:3333/callback"],
    "grant_types":["authorization_code","refresh_token"],
    "response_types":["code"]
  }' | jq
```

The response returns a `client_id` and no `client_secret`.

## Confidential client (optional)

Use this when your app has a trusted backend that can securely store secrets.

```bash
curl -sS -X POST https://flywheel.paradigma.inc/mcp-server/register \
  -H "content-type: application/json" \
  -d '{
    "client_name":"Flywheel MCP Connector Backend",
    "redirect_uris":["https://YOUR_CALLBACK_URL"],
    "grant_types":["authorization_code","refresh_token"],
    "response_types":["code"],
    "token_endpoint_auth_method":"client_secret_post"
  }' | jq
```

That response returns both `client_id` and `client_secret`. Keep `client_secret` private in your backend.
