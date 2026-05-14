# Flywheel CLI Tool Map

Contract-aligned routing guide for the Flywheel runtime CLI.

The Flywheel CLI (`flywheel <command>`) is the runtime command surface shipped by `@paradigma-inc/flywheel`. It wraps the canonical Flywheel HTTP API and is the parallel surface to Flywheel MCP. Use this map when the host install is `--mode cli` (skills installed without an MCP server entry) or whenever scripted / direct-API workflows are preferable to MCP tool calls.

For the MCP routing, see `flywheel-mcp-tool-map.md`. Every entry in the "MCP-equivalent" families below maps one-to-one to an MCP tool there. The "CLI-only" family at the end contains commands with no MCP counterpart.

## Core Contract Expectations

The CLI respects the same contracts the MCP surface enforces. See `flywheel-mcp-tool-map.md`'s "Core Contract Expectations" section for the canonical statements; the additions below are CLI-specific:

- Mutating commands enforce optimistic locking via flags like `--expected_revision`; pass the latest revision token read from `flywheel nodes:get` and handle `409 conflict` with explicit reconciliation.
- Stage-lease coordination mirrors the MCP stage-lease tools: `flywheel nodes:stage:lease:acquire` → `flywheel nodes:stage:lease:heartbeat` (during long edits) → `flywheel nodes:commit` → `flywheel nodes:stage:lease:release`.
- Inline JSON payloads can be supplied with `--payload_json=<json>` or read from a file with `--payload_json=@path/to/file.json`.
- Output format is controlled by `--format json|tsv|csv|table` (default: `json`). Pipe-friendly forms (`tsv`, `csv`) are useful for scripting.
- For artifact uploads, the CLI offers a one-shot `flywheel artifacts:upload` that internally runs prepare + raw PUT + finalize. The split commands (`flywheel artifacts:upload:prepare`, `flywheel artifacts:upload:finalize`) are available for streaming or chunked uploads.
- Run `flywheel help <command>` for canonical per-command flags, types, defaults, examples, and related commands.

## MCP-Equivalent Tool Families

The families below mirror `flywheel-mcp-tool-map.md` and list the canonical CLI equivalent of each MCP tool.

### Discovery and sharing

- `flywheel auth:status` (read; scopes: `read`; HTTP: `GET /auth/status`; MCP equivalent: `flywheel_auth_status`): Show authentication status for the current client context.
- `flywheel credits:balance` (read; scopes: `read`; HTTP: `GET /credits`; MCP equivalent: `flywheel_get_credits_balance`): View credit balance and totals.
- `flywheel updates:list` (read; scopes: `read`; HTTP: `tool-mediated`; MCP equivalent: `flywheel_updates_list`): List in-app announcements relevant to your account.
- `flywheel updates:hide` (mutating; scopes: `write`; HTTP: `POST /updates/{announcement_id}/hide`; MCP equivalent: `flywheel_updates_hide`): Hide a specific announcement.
- `flywheel updates:hide-all-active` (mutating; scopes: `write`; HTTP: `POST /updates/hide-all-active`; MCP equivalent: `flywheel_updates_hide_all_active`): Hide all currently active announcements.
- `flywheel updates:unhide` (mutating; scopes: `write`; HTTP: `DELETE /updates/{announcement_id}/hide`; MCP equivalent: `flywheel_updates_unhide`): Restore a previously hidden announcement.
- `flywheel nodes:list` (read; scopes: `read`; HTTP: `GET /nodes`; MCP equivalent: `flywheel_list_nodes`): List nodes with optional pagination, status, and archive filters.
- `flywheel nodes:resolve-slug` (read; scopes: `read`; HTTP: `GET /nodes/resolve-by-slug`; MCP equivalent: `flywheel_resolve_node_slug`): Resolve a slug to a node ID with explicit conflict handling (`unique`, `context_resolved`, `ambiguous`, `not_found`).
- `flywheel nodes:sharing:get` (read; scopes: `read`; HTTP: `tool-mediated`; MCP equivalent: `flywheel_get_node_sharing`): Get sharing (access policy) for a node.
- `flywheel nodes:sharing:set` (mutating; scopes: `write`; HTTP: `tool-mediated`; MCP equivalent: `flywheel_set_sharing_for_node`): Replace sharing (access policy) for a node.
- `flywheel nodes:sharing:set-bulk` (mutating; scopes: `write`; HTTP: `POST /nodes/access-policy/bulk`; MCP equivalent: `flywheel_set_sharing_for_nodes`): Apply one sharing policy to multiple nodes.
- `flywheel nodes:get` (read; scopes: `read`; HTTP: `tool-mediated`; MCP equivalent: `flywheel_get_node`): Fetch one node by identifier. Relationship arrays are not guaranteed complete; use relationship paging commands for traversal.
- `flywheel nodes:children` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/children`; MCP equivalent: `flywheel_get_node_children`): Page direct visible children with `--first`, `--after`, and `--projection`.
- `flywheel nodes:parents` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/parents`; MCP equivalent: `flywheel_get_node_parents`): Page direct visible parents with `--first`, `--after`, and `--projection`.
- `flywheel tags:create` (mutating; scopes: `write`; HTTP: `POST /nodes/{root_node_id}/tags`; MCP equivalent: `flywheel_create_node_tag`): Create a reusable tag on a graph root.
- `flywheel tags:update` (mutating; scopes: `write`; HTTP: `PATCH /nodes/{root_node_id}/tags/{tag_id}`; MCP equivalent: `flywheel_update_node_tag`): Update a tag definition.
- `flywheel tags:delete` (mutating; scopes: `write`; HTTP: `DELETE /nodes/{root_node_id}/tags/{tag_id}`; MCP equivalent: `flywheel_delete_node_tag`): Delete a tag definition from the graph.
- `flywheel tags:assign` (mutating; scopes: `write`; HTTP: `PUT /nodes/{node_id}/tags`; MCP equivalent: `flywheel_set_node_tag_assignments`): Assign or clear tags on a node (atomic replace; `--tag_ids` accepts comma-separated IDs; `--expected_revision` is required).
- `flywheel nodes:render:tree` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/tree`; MCP equivalent: `flywheel_get_node_tree`): Render a bounded tree projection for a node.
- `flywheel nodes:render:ancestry` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/ancestry`; MCP equivalent: `flywheel_get_node_ancestry`): Render ancestry (roots-ward lineage) for a node.
- `flywheel campaign:snapshot` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/campaign/snapshot`; MCP equivalent: `flywheel_get_campaign_snapshot`): Resolve campaign root snapshot for a node.
- `flywheel nodes:audit:list` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/audit`; MCP equivalent: `flywheel_list_audit`): List audit events for node-level actions.

### Node stage and commit

- `flywheel nodes:commit-new` (mutating; scopes: `write`; HTTP: `POST /nodes/commit-new`; MCP equivalent: `flywheel_commit_new_node`): Create and commit a new node in one request.
- `flywheel nodes:stage:lease:acquire` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/stage/lease/acquire`; MCP equivalent: `flywheel_acquire_stage_lease`): Acquire an edit lease for an existing node.
- `flywheel nodes:stage:lease:heartbeat` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/stage/lease/heartbeat`; MCP equivalent: `flywheel_heartbeat_stage_lease`): Heartbeat an active node stage lease.
- `flywheel nodes:stage:lease:release` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/stage/lease/release`; MCP equivalent: `flywheel_release_stage_lease`): Release a node stage lease.
- `flywheel nodes:commit` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/commit`; MCP equivalent: `flywheel_commit_node`): Commit staged changes to an existing node under an active stage lease with a full `--payload_json` body.
- `flywheel nodes:branch` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/branch`; MCP equivalent: `flywheel_branch_node`): Create a child branch from a node. Preflight with `flywheel nodes:get --format=json` and pass `--expected_revision` for optimistic locking.
- `flywheel nodes:merge` (mutating; scopes: `write`; HTTP: `POST /nodes/merge`; MCP equivalent: `flywheel_merge_nodes`): Merge multiple nodes into one resolved node.
- `flywheel nodes:add-parent` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/parents/add`; MCP equivalent: `flywheel_add_parent`): Add a parent-child edge.
- `flywheel nodes:remove-parent` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/parents/remove`; MCP equivalent: `flywheel_remove_parent`): Remove a parent-child edge.
- `flywheel nodes:delete` (mutating; scopes: `write`; HTTP: `DELETE /nodes/{node_id}`; MCP equivalent: `flywheel_delete_node`): Delete a node by identifier. Requires `--yes`. Modes: `cascade` (delete subtree), `detach_shared` (preserve descendants with surviving parents).
- `flywheel nodes:delete-bulk` (mutating; scopes: `write`; HTTP: `POST /nodes/bulk-delete`; MCP equivalent: `flywheel_bulk_delete_nodes`): Delete multiple node subtrees. Requires `--yes`.

### Artifacts

- `flywheel artifacts:upload:prepare` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/artifacts/uploads/prepare`; MCP equivalent: `flywheel_prepare_artifact_uploads`): Create upload batch with signed per-item upload tickets. Upload raw file bytes to the returned URLs (no JSON metadata wrappers).
- `flywheel artifacts:upload:finalize` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/artifacts/uploads/finalize`; MCP equivalent: `flywheel_finalize_artifact_uploads`): Finalize prepared artifact uploads and attach all staged artifacts in one revision bump.
- `flywheel artifacts:list` (read; scopes: `read`; HTTP: `tool-mediated`; MCP equivalent: `flywheel_list_artifacts`): List artifacts for a node.
- `flywheel artifacts:get` (read; scopes: `read`; HTTP: `tool-mediated`; MCP equivalent: `flywheel_get_artifact`): Fetch one artifact metadata record.
- `flywheel artifacts:delete` (mutating; scopes: `write`; HTTP: `DELETE /nodes/{node_id}/artifacts/{artifact_id}`; MCP equivalent: `flywheel_delete_artifact`): Delete an artifact from a node (optimistic locking).
- `flywheel artifacts:delete-bulk` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/artifacts/bulk-delete`; MCP equivalent: `flywheel_bulk_delete_artifacts`): Delete multiple artifacts from one node. Requires `--yes`.
- `flywheel artifacts:note:set` (mutating; scopes: `write`; HTTP: `PATCH /nodes/{node_id}/artifacts/{artifact_id}/note`; MCP equivalent: `flywheel_set_artifact_note`): Add, update, or clear an artifact note (optimistic locking).

### Executions

- `flywheel executions:launch` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/executions`; MCP equivalent: `flywheel_launch_execution`): Start an execution for a node.
- `flywheel executions:list` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/executions`; MCP equivalent: `flywheel_list_executions`): List executions for a node.
- `flywheel executions:terminate` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/executions/{execution_id}/terminate`; MCP equivalent: `flywheel_terminate_execution`): Stop an execution for a node.

### Compute and budgets

- `flywheel compute:options` (read; scopes: `compute`; HTTP: `GET /compute/catalog`; MCP equivalent: `flywheel_compute_list_options`): List allowed compute catalog options for a node. Use `--node_id`; optionally add `--provider`, `--limit`, or `--detail compact|full`.
- `flywheel compute:funding` (read; scopes: `compute`; HTTP: `GET /compute/funding`; MCP equivalent: `flywheel_compute_funding`): Read grant-scoped funding context (`grant_cents`, `remaining_cents`, backing budget fields) before compute acquire.
- `flywheel compute:status` (read; scopes: `compute`; HTTP: `GET /compute/status`; MCP equivalent: `flywheel_compute_status`): Return compute lease status. Lease rows include ownership flags so hosts can distinguish user-owned leases from sponsor-visible campaign leases.
- `flywheel compute:connection` (read; scopes: `compute`; HTTP: `GET /compute/connection`; MCP equivalent: `flywheel_compute_connection`): Get SSH connection material for a usable lease (token-scoped to `lease_control_token`; only owned leases are connectable).
- `flywheel approval-sessions:heartbeat` (read; scopes: `compute`; HTTP: `POST /approval-sessions/heartbeat`; MCP equivalents: `flywheel_approval_session_open`, `flywheel_approval_session_heartbeat`): Create or refresh a compute approval session for the current host context.
- `flywheel approval-sessions:list` (read; scopes: `compute`; HTTP: `GET /approval-sessions`; MCP equivalent: `flywheel_list_approval_sessions`): List approval sessions visible to the current user.
- `flywheel approval-sessions:expire` (mutating; scopes: `compute`; HTTP: `POST /approval-sessions/expire`; MCP equivalent: `flywheel_expire_approval_session`): Expire the current compute-grant approval session context without releasing active leases.
- `flywheel compute-grants:request-approval` (mutating; scopes: `compute`; HTTP: `tool-mediated`; MCP equivalent: `flywheel_request_compute_grant_approval`): Request compute-grant approval; branch on response status (`already_approved`, `approval_required`, `insufficient_credits`).
- `flywheel compute-grants:list` (read; scopes: `compute`; HTTP: `GET /compute/grants`; MCP equivalent: `flywheel_list_compute_grants`): List active/expired compute grants available to the user. Filter with `--status` and restrict by `--approval_session_id` to inspect session-bound grants.
- `flywheel campaign-budgets:list` (read; scopes: `compute`; HTTP: `GET /nodes/{root_node_id}/campaign-budgets`; MCP equivalent: `flywheel_list_campaign_budgets`): List campaign compute budgets for a root. Organizer-only management view.
- `flywheel campaign-budgets:create` (mutating; scopes: `compute`; HTTP: `POST /nodes/{root_node_id}/campaign-budgets`; MCP equivalent: `flywheel_create_campaign_budget`): Create a campaign compute budget grant.
- `flywheel campaign-budgets:update` (mutating; scopes: `compute`; HTTP: `PATCH /nodes/{root_node_id}/campaign-budgets/{compute_budget_id}`; MCP equivalent: `flywheel_update_campaign_budget`): Update explicit campaign budget fields such as `--hard_cap_cents`, `--per_user_hard_cap_cents`, `--name`, and `--description`.
- `flywheel campaign-budgets:revoke` (mutating; scopes: `compute`; HTTP: `DELETE /nodes/{root_node_id}/campaign-budgets/{compute_budget_id}`; MCP equivalent: `flywheel_revoke_campaign_budget`): Revoke a campaign budget grant.
- `flywheel compute:acquire` (mutating; scopes: `compute`; HTTP: `tool-mediated`; MCP equivalent: `flywheel_compute_acquire`): Acquire managed compute for a node. Set `--requested_sku` to the exact `offer_id` returned by `flywheel compute:options` (`options[].offer_id`), including provider prefixes (e.g., `nebius::...`); do not pass display names or partial IDs. Returns lease state only; poll `flywheel compute:status` for readiness.
- `flywheel compute:release` (mutating; scopes: `compute`; HTTP: `tool-mediated`; MCP equivalent: `flywheel_compute_release`): Release one active compute lease (async; use `--wait` to block).
- `flywheel compute:release-all` (mutating; scopes: `compute`; HTTP: `tool-mediated`; MCP equivalent: `flywheel_compute_release_all`): Release active leases in the current `lease_control_token` scope; `--force --yes` still requires `--lease_control_token` and explicitly broadens cleanup to all current-user active leases.

### Contract, audit, and export

- (no CLI equivalent; MCP equivalent: `flywheel_get_contract`): MCP contract introspection is MCP-only. In `--mode cli` install, treat each command's `flywheel help <command>` output as the canonical per-command contract reference.
- (no CLI equivalent; MCP equivalent: `flywheel_get_contract_section`): Same as above.
- `flywheel export:subgraph` (read; scopes: `read`; HTTP: `POST /export`; MCP equivalent: `flywheel_export_subgraph`): Export a subgraph snapshot. Pass `--include_descendants true` to expand roots to visible descendants, bounded by `--max_nodes`.
- `flywheel import:subgraph` (mutating; scopes: `write`; HTTP: `POST /import`; MCP equivalent: `flywheel_import_subgraph`): Import graph JSON into new node records. Responses include `root_node_ids`, `imported_node_ids`, and `id_mapping`. Pass `--normalize_cycles=true` to drop cycle/self-loop edges; default rejects cyclic payloads.
- `flywheel nodes:render:summary` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/summary`; MCP equivalent: `flywheel_summarize_node_tree`): Render a compact summary of a node subtree.
- `flywheel export:summary` (read; scopes: `read`; HTTP: `POST /export-summary`; MCP equivalent: `flywheel_export_summary`): Generate a markdown summary export.
- `flywheel export:summary:stream` (read; scopes: `read`; HTTP: `POST /export-summary-stream`; MCP equivalent: `flywheel_export_summary_stream`): Stream summary generation as NDJSON events.
- `flywheel export:summary:pdf` (read; scopes: `read`; HTTP: `POST /export-summary-pdf`; MCP equivalent: `flywheel_export_summary_pdf`): Render summary as PDF; requires `--out`.
- `flywheel export:summary:render-pdf` (read; scopes: `read`; HTTP: `POST /export-summary-render-pdf`; MCP equivalent: `flywheel_export_summary_render_pdf`): Render caller-provided markdown as PDF; requires `--out`.

## CLI-Only Tool Families

These commands have no MCP counterpart. They cover auth/profile management, account administration, billing flows, integrations, and bulk file operations that the CLI exposes directly through the canonical HTTP API.

### Auth and profiles

- `flywheel auth:login` (mutating; scopes: `write`): Bootstrap API key auth via RFC 8628 device flow (FLY-416: replaces legacy /setup-exchange redeem).
- `flywheel auth:keychain:set` (local): Store an API key in the OS keychain for a profile. Reads the key from stdin.
- `flywheel auth:keychain:clear` (local): Remove an API key from the OS keychain for a profile.
- `flywheel profile:list` (local): List configured CLI profiles.
- `flywheel profile:show` (local): Show a profile definition.
- `flywheel profile:set` (local): Create or update a CLI profile (never stores plaintext keys).
- `flywheel profile:unset` (local): Delete a CLI profile.

### Node helpers (CLI-only)

- `flywheel nodes:create` (mutating; scopes: `write`): Create a minimal node (title only) and emit graph-change event.
- `flywheel nodes:files` (read; scopes: `read`): List files attached to a node.
- `flywheel nodes:sharing:summaries` (read; scopes: `read`): Read access summaries for multiple nodes in one batch.

### Artifact helpers (CLI-only)

- `flywheel artifacts:upload` (mutating; scopes: `write`): One-shot upload — runs prepare + raw PUT + finalize from a single invocation. Use this in scripts; the prepare/finalize split is for streaming or chunked uploads.

### Compute policy and budgets (CLI-only)

- `flywheel admin:compute:policy:get` (admin-only read; scopes: `compute`): Read compute budget policy for a node.
- `flywheel admin:compute:policy:set` (admin-only mutating; scopes: `compute`): Update explicit compute policy fields such as `--hard_cap_cents`, `--managed_compute_enabled`, `--provider_filters`, `--allowed_offer_ids`, `--preferred_offer_ids`, and `--auto_shutdown_idle_seconds`.
- `flywheel compute:budgets` (read; scopes: `compute`): List budget grants visible for a node context.
- `flywheel machines:list` (read; scopes: `compute`): List your managed compute leases.

### Files, blobs, graph, history (CLI-only)

- `flywheel blobs:get` (read; scopes: `read`): Download a raw blob by storage key.
- `flywheel files:list` (read; scopes: `read`): List all your files across nodes.
- `flywheel graph:get` (read; scopes: `read`): Read the graph projection for navigation and topology workflows. Use `--filter` and `--exclude` for node filter tokens across owner, root_graph, tag, visibility, and recency axes; `node_type` is not a supported axis.
- `flywheel export:history` (read; scopes: `read`): Export node history as JSONL.

### Account

- `flywheel account:get` (read; scopes: `read`): View account snapshot and linked identities.
- `flywheel account:merge:proof` (mutating; scopes: `write`): Mint a merge proof token from a source session token.
- `flywheel account:merge:preview` (read; scopes: `read`): Preview what an account merge will do.
- `flywheel account:merge` (mutating; scopes: `write`): Execute an account merge. Requires `--confirm=MERGE`.
- `flywheel account:detach` (mutating; scopes: `write`): Detach a linked alias account. Requires `--confirm=DETACH`.
- `flywheel account:emails:add` (mutating; scopes: `write`): Add an email alias to your account.
- `flywheel account:emails:remove` (mutating; scopes: `write`): Remove an email alias from your account.
- `flywheel account:emails:set-primary` (mutating; scopes: `write`): Set your primary email address.

Account merge, detach, and email mutation commands are browser-session-bound. API-key-only invocations fail locally with `session_auth_required` and a Web settings deep link (`/app?settings=user`).

### Credits and billing

- `flywheel credits:transactions` (read; scopes: `read`): View paginated credit transactions.
- `flywheel credits:usage` (read; scopes: `read`): Feature-based usage breakdown over a window.
- `flywheel credits:purchase` (mutating; scopes: `write`): Create a Stripe checkout session for a one-time purchase and return `browser_flow_required` with the browser URL.
- `flywheel credits:subscribe` (mutating; scopes: `write`): Create a Stripe checkout session for a subscription and return `browser_flow_required` with the browser URL.
- `flywheel credits:billing-portal` (mutating; scopes: `write`): Open the Stripe billing portal for the current user and return `browser_flow_required` with the browser URL.
- `flywheel credits:subscription` (read; scopes: `read`): View your subscription status.
- `flywheel credits:referral` (read; scopes: `read`): View your referral code and status.
- `flywheel credits:referral:claim` (mutating; scopes: `write`): Claim referral rewards using a code.

### Integrations

- `flywheel github:status` (read; scopes: `read`): Check GitHub connection status.
- `flywheel github:link` (mutating; scopes: `write`): Start the GitHub App install/link browser flow. Does not accept callback installation parameters.
- `flywheel github:refresh-repos` (mutating; scopes: `write`): Refresh the list of accessible repositories.
- `flywheel github:disconnect` (mutating; scopes: `write`): Disconnect GitHub from your account.
- `flywheel integrations:status` (read; scopes: `read`): Check integration connection status (W&B, Hugging Face).
- `flywheel integrations:wandb:set` (mutating; scopes: `write`): Store a Weights & Biases API key. Prefer `--api_key_env WANDB_API_KEY`.
- `flywheel integrations:wandb:remove` (mutating; scopes: `write`): Remove your W&B credential.
- `flywheel integrations:huggingface:set` (mutating; scopes: `write`): Store a Hugging Face access token. Prefer `--token_env HF_TOKEN`; the CLI sends it to the API as `access_token`.
- `flywheel integrations:huggingface:remove` (mutating; scopes: `write`): Remove your Hugging Face credential.

### API keys

- `flywheel api-keys:list` (read; scopes: `read`): List your API keys with bounded pagination (`--limit`, `--offset`); default output is a compact table and `--format=json` preserves the response envelope.
- `flywheel api-keys:create` (mutating; scopes: `write`): Create a new API key and return the raw material once.
- `flywheel api-keys:delete` (mutating; scopes: `write`): Delete an API key (refuses to delete the active one unless `--allow-self`).
- `flywheel api-keys:rotate` (mutating; scopes: `write`): Rotate an API key (refuses to rotate the active one unless `--allow-self`).
  <!-- FLY-416: removed — device flow replaces legacy /setup-exchange. -->
  <!-- - `flywheel api-keys:setup-exchange:create` (mutating; scopes: `write`): Start browser-assisted setup exchange. -->
  <!-- - `flywheel api-keys:setup-exchange:redeem` (mutating; scopes: `write`): Redeem a setup exchange token into a raw API key. -->

## Practical Command Sequences

### List Owned Nodes

1. `flywheel nodes:list --page 1 --page_size 20`.

### Safe Node Update

1. `flywheel nodes:get --node_id=<id>`: Read latest node state and capture `revision`.
2. `flywheel nodes:stage:lease:acquire --node_id=<id> --stage_session_id=<sid> --base_committed_revision=<rev>`: Acquire a session-scoped stage lease.
3. `flywheel nodes:commit --node_id=<id> --payload_json=@payload.json`: Commit once terminal and contract-complete; the payload file includes `stage_session_id`, `base_committed_revision`, and `staged_payload`.

### Empirical Workflow

1. `flywheel nodes:commit-new --payload_json=@new-node.json`: Commit a local staged new node to canonical storage as the first persistence boundary.
2. `flywheel compute:options --node_id=<id> --detail compact`: List allowed offers; pick the exact `offer_id`.
3. `flywheel compute-grants:request-approval --purpose "train" --requested_sku=<offer_id> --budget_source=user --acquire_node_id=<id>`: Request budget approval. Branch on response `status` (`already_approved` | `approval_required` | `insufficient_credits`).
4. If `approval_required`: present `approval_url` to the user, then `flywheel compute-grants:list --status=active --approval_session_id=<sid>` to fetch the active grant.
5. `flywheel compute:acquire --node_id=<id> --compute_grant_id=<gid> --requested_sku=<offer_id> --approval_session_id=<sid>`: Acquire lease.
6. `flywheel compute:status --lease_control_token=<tok>`: Poll until the lease is ready.
7. `flywheel executions:launch --node_id=<id>`: Launch execution.
8. `flywheel executions:list --node_id=<id>`: Poll until execution reaches terminal status.
9. `flywheel artifacts:upload --node_id=<id> --expected_revision=<rev> --items=@items.json`: One-shot upload using an upload item array, for example `[{"local_path":"results.json","artifact_type":"json"}]` (or use the prepare/finalize split for streaming).
10. `flywheel nodes:commit --node_id=<id> --payload_json=@payload.json`: Commit terminal empirical node.

## Runtime Guidance

- `flywheel nodes:resolve-slug` resolves human-facing slug references. If response status is `ambiguous`, ask the user to confirm the intended `node_id` before mutating anything.
- `flywheel nodes:get` reads the current node state before writes; capture `revision` for optimistic-locking writes.
- `flywheel nodes:stage:lease:acquire`, `flywheel nodes:stage:lease:heartbeat`, `flywheel nodes:stage:lease:release` coordinate session-scoped local staged edits for an existing node before commit.
- `flywheel campaign:snapshot` reads the current derived campaign state for a node's root campaign instead of inferring standings from freeform text.
- `flywheel nodes:sharing:get` verifies sharing state after sharing writes before reporting private/shared/public state.
- `flywheel tags:assign` accepts `--tag_ids t1,t2`; use `--tag_ids ""` to clear all assignments and always include `--expected_revision`.
- `flywheel nodes:list` accepts pagination plus status/archive filters such as `--page`, `--page_size`, `--status`, and `--include_archived`.
- `flywheel compute:status` checks first when work may need managed compute (GPU), using the active `--lease_control_token` from prior acquire (or pass it explicitly).
- `flywheel compute-grants:list` lists active compute grants and selects one `--compute_grant_id` for acquisition.
- `flywheel compute-grants:request-approval` requests/confirms budget before acquire and chooses a budget source (`user` or `root`); branch on status (`already_approved`, `approval_required`, `insufficient_credits`).
- `flywheel compute:connection` reads SSH connection material for the active user lease once status indicates the lease is usable, scoped by `--lease_control_token`.
- `flywheel compute:options` is used when a lease is needed and no suitable active lease exists; copy the exact provider-qualified `offer_id` (`provider::offer_id`) and `region` from `options[].offer_id` verbatim. Catalog-only read; excludes grant/budget money fields.
- `flywheel compute:funding` reads grant-scoped funding context (`grant_cents`, `remaining_cents`, backing budget fields) for the selected `--compute_grant_id` before acquire.
- `flywheel compute:acquire` provisions compute once requirements are clear. Requires a valid `--compute_grant_id`; set `--requested_sku` to the exact selected `options[].offer_id`; returns lease/provisioning state only (not SSH key material). Capture `compute.lease_control_token` from the response for follow-up lease control commands.
- `flywheel compute:release` releases compute when no longer needed, scoped by `--lease_control_token`. Use `--wait` to block until release completes.
- `flywheel executions:launch`, `flywheel executions:list`, `flywheel executions:terminate` manage execution status transitions.
- `flywheel artifacts:upload:prepare` prepares one or more signed raw-file upload requests for concrete deliverables/evidence produced by the work. `flywheel artifacts:upload` is the one-shot convenience wrapper for typical scripts.
- `flywheel artifacts:upload:finalize` finalizes a staged artifact batch and appends all uploaded artifacts in one revision bump.
- `flywheel artifacts:delete` removes an accidental/obsolete node artifact.
- `flywheel artifacts:list`, `flywheel artifacts:get` inspect node artifact metadata (`title` is the display label) and consume `storage_url` for raw artifact bytes only.
- `flywheel nodes:commit-new`, `flywheel nodes:commit` publish the caller's full staged payload once terminal and contract-complete; commit on an existing node requires an active stage lease and a `--payload_json` body with explicit `base_committed_revision`.

## See Also

- `flywheel-mcp-tool-map.md` — the matching MCP routing reference.
- `flywheel help <command>` — canonical per-command flags, types, defaults, examples, and related commands.
- `flywheel --format json|tsv|csv|table` — output format selector for scripting workflows.
