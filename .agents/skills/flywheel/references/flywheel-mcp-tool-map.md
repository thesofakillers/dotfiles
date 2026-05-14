# Flywheel MCP Tool Map

Contract-aligned routing guide for Flywheel MCP tool usage.

Flywheel is a graph-based system for tracking research work, decisions, and evidence over time. Flywheel MCP is the tool interface for reading and updating that graph. You can discover, create, and manage nodes. You can collaborate with other users and use managed compute.

## Core Contract Expectations

- Use `flywheel_get_contract` + `flywheel_get_contract_section` as canonical contract references.
- Node state is canonical durable state; avoid relying on ephemeral transcript state.
- Node body state is `title`, Markdown `content`, and optional `summary`; represent observations, decisions, experiments, and evidence with Markdown structure, tags, artifacts, and executions.
- Node references include immutable `node_id` and optional immutable `slug_name`; prefer communicating both together for human clarity and disambiguation.
- Graph topology should encode logical/causal relations between concepts and experiments. Avoid defaulting to shallow root-only branching unless work items are truly independent.
- Node staging is local (non-canonical) and commit is the only canonical persistence boundary (`commit_new_node`, `commit_node`).
- Mutating node writes are optimistic-locking operations: read latest state, pass `expected_revision` or `base_committed_revision` as required, and handle `409 conflict` with explicit reconciliation.
- Mutating operations are idempotent; MCP tool transport auto-manages `Idempotency-Key` on mutating tool calls.
- Existing-node field editing may use a session-scoped stage lease (`flywheel_acquire_stage_lease`, `flywheel_heartbeat_stage_lease`, `flywheel_release_stage_lease`) to coordinate local staged state before commit.
- Existing-node commit publishes a full staged payload under an active stage lease: commit requests require `stage_session_id`, `base_committed_revision`, and `staged_payload`; conflicts on stale committed revisions are surfaced directly and are not transport-retried.
- Committed node state uses the same canonical body fields for every node; `summary` may be empty when the node body is intentionally represented by content, artifacts, tags, or executions.
- When code is involved, pass `repo_url`/`branch_name`/`head_commit_sha` and align git structure with graph topology where practical (without forcing one-to-one mapping).
- Content, summaries, and artifacts should be reproduction-grade: enough setup, method, evidence, and interpretation for another reader to reproduce or audit results.
- Empirical workflow is hypothesis-driven: launch execution, inspect outcomes, publish evidence artifacts, and commit only after terminal status.
- For empirical work, publish evidence with `flywheel_prepare_artifact_uploads`, upload raw file bytes, then `flywheel_finalize_artifact_uploads` before commit.
- Artifact metadata records expose a non-empty `title` suitable for display labels; title normalization must never derive from `storage_url`.
- Mutating tools are subject to per-user write limits: 120 node creates per minute, 2,000 node creates per 24 hours, and 120 graph writes per minute. Graph writes include existing-node commits, edge changes, deletes, merges, tags, sharing, artifact finalization, artifact deletion, and artifact-note updates. On `429`, honor `Retry-After` and retry the same idempotent write after waiting.

## Tool Families

### Discovery and sharing

- `flywheel_auth_status` (read; scopes: `read`; HTTP: `GET /auth/status`; core surface): Return Flywheel auth status for the current access token.
- `flywheel_get_credits_balance` (read; scopes: `read`; HTTP: `GET /credits`; core surface): Return current user credits balance and lifetime counters.
- `flywheel_updates_list` (read; scopes: `read`; HTTP: `tool-mediated`; core surface): List in-app updates/announcements for the signed-in user.
- `flywheel_updates_hide` (mutating; scopes: `write`; HTTP: `POST /updates/{announcement_id}/hide`; core surface): Mark one update as hidden for the current user (Don't show again).
- `flywheel_updates_hide_all_active` (mutating; scopes: `write`; HTTP: `POST /updates/hide-all-active`; core surface): Hide all active updates for the current user (Don't show all active again).
- `flywheel_updates_unhide` (mutating; scopes: `write`; HTTP: `DELETE /updates/{announcement_id}/hide`; core surface): Restore one hidden update for the current user.
- `flywheel_list_nodes` (read; scopes: `read`; HTTP: `GET /nodes`; full-surface only): List nodes with optional owners/writers/visibility filters and projection control (`core`, `topology`, `full`).
- `flywheel_resolve_node_slug` (read; scopes: `read`; HTTP: `GET /nodes/resolve-by-slug`; core surface): Resolve a node by slug_name with explicit conflict handling (`unique`, `context_resolved`, `ambiguous`, `not_found`).
- `flywheel_get_node_sharing` (read; scopes: `read`; HTTP: `tool-mediated`; full-surface only): Get node sharing for one node (owner/collaborators/visibility).
- `flywheel_set_sharing_for_node` (mutating; scopes: `write`; HTTP: `tool-mediated`; full-surface only): Set sharing for one owned node (collaborators/private-unlisted-public visibility).
- `flywheel_set_sharing_for_nodes` (mutating; scopes: `write`; HTTP: `POST /nodes/access-policy/bulk`; full-surface only): Apply one sharing configuration across multiple owned nodes in bulk.
- `flywheel_get_node` (read; scopes: `read`; HTTP: `tool-mediated`; core surface): Get one node by node_id. Relationship arrays are not guaranteed complete; use relationship paging tools for traversal.
- `flywheel_get_node_children` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/children`; core surface): Page direct visible children with `first`, `after`, and `projection`.
- `flywheel_get_node_parents` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/parents`; core surface): Page direct visible parents with `first`, `after`, and `projection`.
- `flywheel_create_node_tag` (mutating; scopes: `write`; HTTP: `POST /nodes/{root_node_id}/tags`; full-surface only): Create one graph tag from a root node. `track_history` is effective only when `one_only=true`; when `one_only=false`, the effective track_history=false.
- `flywheel_update_node_tag` (mutating; scopes: `write`; HTTP: `PATCH /nodes/{root_node_id}/tags/{tag_id}`; full-surface only): Update one graph tag from a root node.
- `flywheel_delete_node_tag` (mutating; scopes: `write`; HTTP: `DELETE /nodes/{root_node_id}/tags/{tag_id}`; full-surface only): Delete one graph tag from a root node.
- `flywheel_set_node_tag_assignments` (mutating; scopes: `write`; HTTP: `PUT /nodes/{node_id}/tags`; full-surface only): Set graph tag assignments for one node (`tag_ids` must be a JSON array of strings; omit `tag_ids` to clear all assignments to `[]`).
- `flywheel_get_node_tree` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/tree`; full-surface only): Get a root-aware bounded tree/DAG projection for an anchor node.
- `flywheel_get_node_ancestry` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/ancestry`; full-surface only): Get ordered ancestry metadata from an anchor node to root boundaries.
- `flywheel_get_campaign_snapshot` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/campaign/snapshot`; core surface): Read the current campaign snapshot for a node's root campaign, including configured views and derived records.
- `flywheel_list_audit` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/audit`; full-surface only): List node MCP audit events.

### Node stage and commit

- `flywheel_commit_new_node` (mutating; scopes: `write`; HTTP: `POST /nodes/commit-new`; full-surface only): Commit a locally staged new node into canonical storage and return the persisted node.
- `flywheel_acquire_stage_lease` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/stage/lease/acquire`; full-surface only): Acquire a session-scoped stage lease for an existing node before local staged edits.
- `flywheel_heartbeat_stage_lease` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/stage/lease/heartbeat`; full-surface only): Refresh the active stage lease for the current editing session.
- `flywheel_release_stage_lease` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/stage/lease/release`; full-surface only): Release the active stage lease for the current editing session.
- `flywheel_commit_node` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/commit`; core surface): Commit an existing node by publishing the caller's staged payload under an active stage lease.
- `flywheel_branch_node` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/branch`; full-surface only): Create a child branch node with optimistic locking (`expected_revision` required); on 409, reread the node and retry with the current revision.
- `flywheel_merge_nodes` (mutating; scopes: `write`; HTTP: `POST /nodes/merge`; full-surface only): Merge nodes with caller-resolved node payload.
- `flywheel_add_parent` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/parents/add`; full-surface only): Attach an additional parent edge to an existing node (keeps node identity, validates against cycles).
- `flywheel_remove_parent` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/parents/remove`; full-surface only): Detach one parent edge from a node without deleting the node.
- `flywheel_delete_node` (mutating; scopes: `write`; HTTP: `DELETE /nodes/{node_id}`; full-surface only): Delete a node and its descendants. Modes: `cascade` (delete full subtree), `detach_shared` (preserve descendants with surviving parents).
- `flywheel_bulk_delete_nodes` (mutating; scopes: `write`; HTTP: `POST /nodes/bulk-delete`; full-surface only): Delete multiple node subtrees in one operation.

### Artifacts

- `flywheel_prepare_artifact_uploads` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/artifacts/uploads/prepare`; core surface): Prepare one or more raw-file artifact uploads (returns batch token + signed upload URLs). Upload must send raw file bytes to the returned URLs (do not upload JSON metadata wrappers).
- `flywheel_finalize_artifact_uploads` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/artifacts/uploads/finalize`; core surface): Finalize a prepared artifact upload batch and append all staged artifacts to the node in one revision bump.
- `flywheel_resolve_remote_artifact` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/remote-artifacts/resolve`; core surface): Resolve and materialize a public HTTPS JSON remote artifact for a node, using the cached artifact when it is still fresh.
- `flywheel_refresh_remote_artifact` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/remote-artifacts/refresh`; core surface): Force refresh and materialize a public HTTPS JSON remote artifact for a node.
- `flywheel_list_artifacts` (read; scopes: `read`; HTTP: `tool-mediated`; core surface): List node artifacts.
- `flywheel_get_artifact` (read; scopes: `read`; HTTP: `tool-mediated`; core surface): Get one artifact by id.
- `flywheel_delete_artifact` (mutating; scopes: `write`; HTTP: `DELETE /nodes/{node_id}/artifacts/{artifact_id}`; core surface): Delete one artifact by id with optimistic locking.
- `flywheel_bulk_delete_artifacts` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/artifacts/bulk-delete`; core surface): Delete multiple artifacts from one node by explicit artifact IDs with optimistic locking.
- `flywheel_set_artifact_note` (mutating; scopes: `write`; HTTP: `PATCH /nodes/{node_id}/artifacts/{artifact_id}/note`; core surface): Set or clear one artifact note with optimistic locking.

### Hooks

- `flywheel_create_hook` (mutating; scopes: `write`; HTTP: `POST /nodes/{owner_node_id}/hooks`; core surface): Create a durable hook definition on the owner node.
- `flywheel_update_hook` (mutating; scopes: `write`; HTTP: `PATCH /nodes/{owner_node_id}/hooks/{hook_id}`; core surface): Update an existing hook definition.
- `flywheel_set_hook_enabled` (mutating; scopes: `write`; HTTP: `PATCH /nodes/{owner_node_id}/hooks/{hook_id}/enabled`; core surface): Enable/disable a hook without deleting it.
- `flywheel_delete_hook` (mutating; scopes: `write`; HTTP: `DELETE /nodes/{owner_node_id}/hooks/{hook_id}`; core surface): Delete a hook definition.
- `flywheel_list_hooks` (read; scopes: `read`; HTTP: `GET /nodes/{owner_node_id}/hooks`; core surface): List hooks configured on the owner node.
- `flywheel_create_hook_secret` (mutating; scopes: `write`; HTTP: `POST /nodes/{owner_node_id}/hook-secrets`; core surface): Create a hook secret (plaintext is write-only).
- `flywheel_update_hook_secret` (mutating; scopes: `write`; HTTP: `PATCH /nodes/{owner_node_id}/hook-secrets/{secret_id}`; core surface): Update hook secret metadata/value.
- `flywheel_delete_hook_secret` (mutating; scopes: `write`; HTTP: `DELETE /nodes/{owner_node_id}/hook-secrets/{secret_id}`; core surface): Delete a hook secret.
- `flywheel_list_hook_secrets` (read; scopes: `write`; HTTP: `GET /nodes/{owner_node_id}/hook-secrets`; core surface): List hook secret metadata (no plaintext values).
- `flywheel_list_hook_runs` (read; scopes: `read`; HTTP: `GET /nodes/{owner_node_id}/hook-runs`; core surface): List async hook execution runs for observability.

Hook workflow-if contract (first version):

- Supported trigger events are `artifact.finalized` and `node.published`.
- Author matching filters with `workflow_yaml.if` on `flywheel_create_hook` / `flywheel_update_hook`.
- Read/list surfaces return canonical `workflow` plus normalized `workflow_yaml`.
- Workflow-if operators: `all`, `any`, `not`, `event`, `any_artifact`; predicate operators: `eq`, `in`, `exists`.
- Canonical none-artifact expression: `not: { any_artifact: ... }`.
- Run cardinality is fixed at one run per `(hook_id, event_id)` (no artifact fanout).
- Submission-only matching is typically `any_artifact.field=metadata.campaign_role` with `eq: submission`.
- Campaign submission artifacts are valid only on public attempt nodes; private and unlisted submissions do not count in campaign snapshots or dispatch `artifact.finalized` submission hook runs. If an eligible submission artifact is finalized while private, `node.published` can dispatch the matching hook after the attempt becomes public.
- Workflow step types include `flywheel/http_request@v1`, `flywheel/http_poll@v1`, `flywheel/json_extract@v1`, `flywheel/load_artifact@v1`, `flywheel/upsert_artifact@v1`, and `flywheel/add_node_tags@v1`.
- `flywheel/upsert_artifact@v1` selectors are authored under `with.match`; `match.metadata` is subset matching and ambiguous selectors fail terminally.
- `flywheel/add_node_tags@v1` adds ordinary root graph tags to a target node and preserves existing tag assignments; one-only tags are rejected in v1.

### Executions

- `flywheel_launch_execution` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/executions`; core surface): Launch node execution.
- `flywheel_list_executions` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/executions`; core surface): List node executions.
- `flywheel_terminate_execution` (mutating; scopes: `write`; HTTP: `POST /nodes/{node_id}/executions/{execution_id}/terminate`; core surface): Terminate a node execution.

### Compute and budgets

- `flywheel_compute_list_options` (read; scopes: `compute`; HTTP: `GET /compute/catalog`; core surface): List managed compute options allowed for a node. When using grant-backed compute, pass the same compute_grant_id you will use for acquire.
- `flywheel_compute_funding` (read; scopes: `compute`; HTTP: `GET /compute/funding`; core surface): Read grant-scoped funding context (`grant_cents`, `remaining_cents`, and backing budget fields) for a `compute_grant_id` before compute acquire.
- `flywheel_compute_status` (read; scopes: `compute`; HTTP: `GET /compute/status`; core surface): Read managed compute lease status for the current user and current lease_control_token scope. Lease rows include ownership flags so hosts can distinguish user-owned leases from sponsor-visible campaign leases. When checking a grant-backed lease, reuse the same compute_grant_id passed to acquire.
- `flywheel_compute_connection` (read; scopes: `compute`; HTTP: `GET /compute/connection`; core surface): Read SSH connection material for an active managed compute lease once flywheel_compute_status indicates the lease is usable. This tool is token-scoped to lease_control_token and only leases owned by the current user are connectable. Pass lease_id or node_id to disambiguate when needed.
- `flywheel_approval_session_open` (read; scopes: `compute`; HTTP: `tool-mediated`; core surface): Create a new approval session with a server-minted session_id for compute-grant approval flows.
- `flywheel_approval_session_heartbeat` (read; scopes: `compute`; HTTP: `POST /approval-sessions/heartbeat`; core surface): Refresh an existing compute-grant approval session for the current MCP host session.
- `flywheel_list_approval_sessions` (read; scopes: `compute`; HTTP: `GET /approval-sessions`; core surface): List approval sessions visible to the current user.
- `flywheel_expire_approval_session` (mutating; scopes: `compute`; HTTP: `POST /approval-sessions/expire`; core surface): Expire the current compute-grant approval session context without releasing active leases.
- `flywheel_request_compute_grant_approval` (mutating; scopes: `compute`; HTTP: `tool-mediated`; core surface): Request budget approval context before managed compute acquisition; branch on response status.
- `flywheel_list_compute_grants` (read; scopes: `compute`; HTTP: `GET /compute/grants`; core surface): List active/expired compute grants available to the current user.
- `flywheel_list_campaign_budgets` (read; scopes: `compute`; HTTP: `GET /nodes/{root_node_id}/campaign-budgets`; full-surface only): List campaign compute budgets for a campaign root. Organizer-only management view.
- `flywheel_create_campaign_budget` (mutating; scopes: `compute`; HTTP: `POST /nodes/{root_node_id}/campaign-budgets`; full-surface only): Create an organizer-funded campaign compute budget shared with participants.
- `flywheel_update_campaign_budget` (mutating; scopes: `compute`; HTTP: `PATCH /nodes/{root_node_id}/campaign-budgets/{compute_budget_id}`; full-surface only): Update hard caps or metadata for an organizer-funded campaign compute budget.
- `flywheel_revoke_campaign_budget` (mutating; scopes: `compute`; HTTP: `DELETE /nodes/{root_node_id}/campaign-budgets/{compute_budget_id}`; full-surface only): Revoke an organizer-funded campaign compute budget.
- `flywheel_compute_acquire` (mutating; scopes: `compute`; HTTP: `tool-mediated`; core surface): Acquire managed compute for a node with explicit SKU + region and required compute_grant_id (returns accepted/completed lease state only; poll flywheel_compute_status for readiness, not SSH key material). This tool forwards approval_session_id. Set `requested_sku` to the exact `offer_id` returned by `flywheel_compute_list_options` (`options[].offer_id`), including provider prefixes (for example `nebius::...`); do not pass display names or partial IDs.
- `flywheel_compute_release` (mutating; scopes: `compute`; HTTP: `tool-mediated`; core surface): Asynchronously release one managed compute lease by lease_id within the current lease_control_token scope.
- `flywheel_compute_release_all` (mutating; scopes: `compute`; HTTP: `tool-mediated`; core surface): Asynchronously release active managed compute leases in the current lease_control_token scope; set `force=true` with `lease_control_token` for explicit account-wide cleanup for the current user.

### Contract, audit, and export

- `flywheel_get_contract` (read; scopes: `read`; HTTP: `GET /mcp/contract`; core surface): Return Flywheel MCP contract overview (scopes, write safety, operation catalog, and section index).
- `flywheel_get_contract_section` (read; scopes: `read`; HTTP: `GET /mcp/contract/sections/{section_id}`; core surface): Return one contract section by section_id (for example `graph` or `campaign/template_v1`).
- `flywheel_export_subgraph` (read; scopes: `read`; HTTP: `POST /export`; full-surface only): Export selected graph/subgraph nodes as JSON. Set `include_descendants=true` to expand each requested root to visible descendants, bounded by `max_nodes`.
- `flywheel_import_subgraph` (mutating; scopes: `write`; HTTP: `POST /import`; full-surface only): Import graph/subgraph JSON payload into new node IDs. Set normalize_cycles=true to drop cycle/self-loop edges; default rejects cyclic payloads.
- `flywheel_summarize_node_tree` (read; scopes: `read`; HTTP: `GET /nodes/{node_id}/summary`; full-surface only): Summarize a node tree using node fields only.
- `flywheel_export_summary` (read; scopes: `read`; HTTP: `POST /export-summary`; full-surface only): Generate markdown summary for selected nodes.
- `flywheel_export_summary_stream` (read; scopes: `read`; HTTP: `POST /export-summary-stream`; full-surface only): Generate summary stream events for selected nodes.
- `flywheel_export_summary_pdf` (read; scopes: `read`; HTTP: `POST /export-summary-pdf`; full-surface only): Generate PDF summary for selected nodes.
- `flywheel_export_summary_render_pdf` (read; scopes: `read`; HTTP: `POST /export-summary-render-pdf`; full-surface only): Render provided markdown to PDF and embed export metadata.

## Practical Tool Sequences

### List Owned Nodes

1. `flywheel_list_nodes` with `{'owners': ['me'], 'projection': 'core'}`.

### Safe Node Update

1. `flywheel_get_node`: Read latest node state before mutating fields.
2. `flywheel_acquire_stage_lease`: Acquire a session-scoped stage lease before editing an existing node locally.
3. `flywheel_commit_node`: Commit with `stage_session_id`, `base_committed_revision`, and full `staged_payload` once terminal and contract-complete.

### Empirical Workflow

1. `flywheel_commit_new_node`: Commit a local staged new node to canonical storage as the first persistence boundary.
2. `flywheel_commit_node`: Commit staged empirical fields with `stage_session_id`, `base_committed_revision`, and a full `staged_payload` once the working state is ready to publish.
3. `flywheel_request_compute_grant_approval`: If compute is needed, request budget approval context first. Branch on response status.
4. Branch on `flywheel_request_compute_grant_approval.status`: Branch by response status (`already_approved`, `approval_required`, `insufficient_credits`).. if `already_approved` then `reuse_compute_grant_id`: Use returned `compute_grant_id` directly for flywheel_compute_acquire.. if `approval_required` then `present_approval_url_to_user`: Present `approval_url` to the user; the user opens it and confirms budget approval.; `flywheel_list_compute_grants`: After approval, list active grants for the current `approval_session_id` and use the returned `compute_grant_id` for acquire.. if `insufficient_credits` then `request_user_credit_top_up`: No `approval_url` is returned. Ask the user to add credits, then retry flywheel_request_compute_grant_approval.
5. `flywheel_compute_acquire`: Acquire lease with `compute_grant_id`; include `approval_session_id` from approval response and set `requested_sku` to the exact selected `options[].offer_id`.
6. `flywheel_compute_status`: Poll until the active lease is ready; follow `recommended_next_action`.
7. `flywheel_launch_execution`: Launch execution once compute and inputs are ready.
8. `flywheel_list_executions`: Poll until execution reaches terminal status.
9. `flywheel_prepare_artifact_uploads`: Prepare signed upload URLs for empirical evidence.
10. `raw_file_upload`: Upload raw bytes to each signed URL with required headers.
11. `flywheel_finalize_artifact_uploads`: Finalize prepared uploads before commit when the work produced evidence artifacts.
12. `flywheel_commit_node`: Commit terminal empirical node once contract requirements are satisfied.

### Hook Automation Workflow

1. `flywheel_create_hook_secret`: Create endpoint credentials if the action needs auth.
2. `flywheel_create_hook`: Define `workflow_yaml.on`, scope, `workflow_yaml.if`, and `jobs.main.steps`.
3. `flywheel_set_hook_enabled`: Enable hook once configuration is complete.
4. `flywheel_list_hooks`: Confirm the hook is enabled and scoped correctly.
5. `flywheel_finalize_artifact_uploads` or `flywheel_set_sharing_for_node`: Emit `artifact.finalized` on successful finalize writes or `node.published` when an eligible submission node becomes public.
6. `flywheel_list_hook_runs`: Inspect run outcomes (`queued`, `running`, `succeeded`, `failed`).

## Runtime Guidance

- `flywheel_resolve_node_slug`: resolve human-facing slug references. If response status is `ambiguous`, ask the user to confirm the intended node_id before mutating anything.
- `flywheel_get_node`: read the current node state before writes.
- `flywheel_acquire_stage_lease`, `flywheel_heartbeat_stage_lease`, `flywheel_release_stage_lease`: coordinate session-scoped local staged edits for an existing node before commit.
- `flywheel_get_campaign_snapshot`: read the current derived campaign state for this node's root campaign instead of inferring standings from freeform text.
- `flywheel_get_node_sharing`: after sharing writes, verify with flywheel_get_node_sharing before reporting private/shared/public state.
- `flywheel_set_node_tag_assignments`: pass `tag_ids` as a JSON array of strings; omitting `tag_ids` clears all assignments (`[]`).
- `flywheel_list_nodes`: canonical filter inputs for `owners`, `writers`, and `visibility` are arrays; scalar `owners`/`writers` may be normalized by transport compatibility layers, but array form is preferred.
- `flywheel_compute_status`: check first when work may need managed compute (GPU), using the active lease_control_token from host context (or pass it explicitly).
- `flywheel_list_compute_grants`: list active compute grants (funded by user/root budgets) and select one `compute_grant_id` for acquisition.
- `flywheel_request_compute_grant_approval`: request/confirm budget before acquire and choose a budget source (`user` or `root`); branch on status (`already_approved`, `approval_required`, `insufficient_credits`).
- `flywheel_compute_connection`: read SSH connection material for the active user lease once status indicates the lease is usable, scoped by lease_control_token.
- `flywheel_compute_list_options`: use when a lease is needed and no suitable active lease exists, then select the exact provider-qualified `offer_id` from `options[].offer_id` (`provider::offer_id`) and `region`. Copy `offer_id` verbatim; do not strip prefixes or substitute display names. This is a catalog-only read and excludes grant/budget money fields.
- `flywheel_compute_funding`: read grant-scoped funding context (`grant_cents`, `remaining_cents`, backing budget fields) for the selected `compute_grant_id` before acquire.
- `flywheel_compute_acquire`: provision compute once requirements are clear. This requires a valid `compute_grant_id`; set `requested_sku` to the exact selected `options[].offer_id`; and returns lease/provisioning state only (not SSH key material). Capture `compute.lease_control_token` from the response for follow-up lease control tools.
- `flywheel_compute_release`: release compute when no longer needed, scoped by lease_control_token.
- `flywheel_launch_execution`, `flywheel_list_executions`, `flywheel_terminate_execution`: manage execution status transitions.
- `flywheel_prepare_artifact_uploads`: prepare one or more signed raw-file upload requests for concrete deliverables/evidence produced by the work.
- `flywheel_finalize_artifact_uploads`: finalize a staged artifact batch and append all uploaded artifacts in one revision bump.
- `flywheel_delete_artifact`: remove an accidental/obsolete node artifact.
- `flywheel_list_artifacts`, `flywheel_get_artifact`: inspect node artifact metadata (`title` is the display label) and consume `storage_url` for raw artifact bytes only.
- `flywheel_commit_new_node`, `flywheel_commit_node`: publish the caller's full staged payload for an existing node once terminal and contract-complete; requires an active stage lease and explicit `base_committed_revision`.

### Admin only (FLY-359)

These tools require an `@paradigma.inc`-authenticated MCP session **or** a valid `X-Admin-Key` header sent on the MCP HTTP request. The MCP streamable HTTP mount reads `X-Admin-Key` from the inbound request and forwards it through to the in-process `/admin/graphs*` call; on admin paths the proxy also suppresses the session bearer to sidestep the API-key route allowlist check. `require_paradigma_admin` then grants access based on the admin key. The routes are omitted from the public OpenAPI schema and from the API-key allowlist.

- `flywheel_admin_list_graphs`: list every root-node graph across all users. Filters: `tag_id`, `owner_user_id`, `created_after`, `created_before`, `cursor`, `page_size` (1..200). Returns `{graphs, has_more, next_cursor}`.
- `flywheel_admin_export_graph`: export one graph by `root_node_id` as canonical JSON (`{version, exported_at, node_count, nodes}`). Bypasses per-caller node-visibility checks by design.
- `flywheel_admin_export_graphs_stream`: batch-export one page of canonical graph JSON payloads matching the filter; iterate pages via `next_cursor`. The NDJSON HTTP endpoint (`GET /admin/graphs/export.jsonl`) is the CLI-first streaming surface; the MCP tool materializes a page to fit the RPC model.
