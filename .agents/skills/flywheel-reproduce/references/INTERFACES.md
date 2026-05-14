# Interfaces

Canonical reference for Flywheel MCP public interfaces and contract pointers.

## Canonical Contract References

- `flywheel_get_contract` is the top-level contract entry point.
- `flywheel_get_contract_section(section_id)` returns section-scoped payloads.
- Section order:
- `quickstart` (Quickstart): Recommended first calls and section read order for onboarding.
- `graph` (Graph): Node model, graph topology guidance, and durable behavior rules.
- `stage_commit` (Stage and commit): Stage/commit operations, commit-time validation requirements, and reproducibility guidance.
- `sharing` (Sharing): Sharing modes, derived visibility, collaborator roles, and query translation.
- `artifacts` (Artifacts): Prepare/upload/finalize requirements and artifact type rules.
- `compute` (Compute): Lease ownership, token-scoped control, approval session, and budget source semantics.
- `compute/troubleshooting_v1` (Compute Troubleshooting v1): Provider-specific acquire/retry hints for launch kwargs and request tuning.
- `campaign` (Campaign Contract): Campaign projection and budget contracts plus template section pointers.

## Canonical Entity Model

- Canonical durable entity: `node`.
- Canonical node body fields: `title`, Markdown `content`, and optional `summary`.
- Node references: `node_id`, `slug_name`.
- `slug_name` format: `adjective-noun-####` (immutable when present).
- Removed typed node body fields (`kind`, `node_type`, `hypothesis`, `insights`, `no_artifacts_reason`) are not write fields.
- Approval sessions and compute grants are distinct entities; approvals are session-scoped bindings.
- Campaign projections are derived from root config and attempt submission JSON artifacts.

Node detail reads are cardinality-safe: `flywheel_get_node` / `GET /nodes/{node_id}`
return node fields plus `has_children` / `has_parents` presence booleans, but do
not guarantee complete `incoming_ids` or `outgoing_ids` arrays. Use
`flywheel_get_node_children` / `GET /nodes/{node_id}/children` and
`flywheel_get_node_parents` / `GET /nodes/{node_id}/parents` for complete
direct-neighbor traversal.

## MCP Tool Surface

### Discovery and sharing

- `flywheel_auth_status` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_get_credits_balance` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_updates_list` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_updates_hide` (mutating; scopes: `write`; core surface; binding: `operation`)
- `flywheel_updates_hide_all_active` (mutating; scopes: `write`; core surface; binding: `operation`)
- `flywheel_updates_unhide` (mutating; scopes: `write`; core surface; binding: `operation`)
- `flywheel_list_nodes` (read; scopes: `read`; full-surface only; binding: `operation`)
- `flywheel_resolve_node_slug` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_get_node_sharing` (read; scopes: `read`; full-surface only; binding: `operation`)
- `flywheel_set_sharing_for_node` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_set_sharing_for_nodes` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_get_node` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_get_node_children` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_get_node_parents` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_create_node_tag` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_update_node_tag` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_delete_node_tag` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_set_node_tag_assignments` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_get_node_tree` (read; scopes: `read`; full-surface only; binding: `operation`)
- `flywheel_get_node_ancestry` (read; scopes: `read`; full-surface only; binding: `operation`)
- `flywheel_get_campaign_snapshot` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_list_audit` (read; scopes: `read`; full-surface only; binding: `operation`)

### Node stage and commit

- `flywheel_commit_new_node` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_acquire_stage_lease` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_heartbeat_stage_lease` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_release_stage_lease` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_commit_node` (mutating; scopes: `write`; core surface; binding: `operation`)
- `flywheel_branch_node` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_merge_nodes` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_add_parent` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_remove_parent` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_delete_node` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_bulk_delete_nodes` (mutating; scopes: `write`; full-surface only; binding: `operation`)

### Artifacts

- `flywheel_prepare_artifact_uploads` (mutating; scopes: `write`; core surface; binding: `binding_helper`)
- `flywheel_finalize_artifact_uploads` (mutating; scopes: `write`; core surface; binding: `binding_helper`)
- `flywheel_list_artifacts` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_get_artifact` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_delete_artifact` (mutating; scopes: `write`; core surface; binding: `operation`)
- `flywheel_bulk_delete_artifacts` (mutating; scopes: `write`; core surface; binding: `operation`)
- `flywheel_set_artifact_note` (mutating; scopes: `write`; core surface; binding: `operation`)

### Executions

- `flywheel_launch_execution` (mutating; scopes: `write`; core surface; binding: `operation`)
- `flywheel_list_executions` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_terminate_execution` (mutating; scopes: `write`; core surface; binding: `operation`)

### Compute and budgets

- `flywheel_compute_list_options` (read; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_compute_funding` (read; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_compute_status` (read; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_compute_connection` (read; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_approval_session_open` (read; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_approval_session_heartbeat` (read; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_list_approval_sessions` (read; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_expire_approval_session` (mutating; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_request_compute_grant_approval` (mutating; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_list_compute_grants` (read; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_list_campaign_budgets` (read; scopes: `compute`; full-surface only; binding: `operation`)
- `flywheel_create_campaign_budget` (mutating; scopes: `compute`; full-surface only; binding: `operation`)
- `flywheel_update_campaign_budget` (mutating; scopes: `compute`; full-surface only; binding: `operation`)
- `flywheel_revoke_campaign_budget` (mutating; scopes: `compute`; full-surface only; binding: `operation`)
- `flywheel_compute_acquire` (mutating; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_compute_release` (mutating; scopes: `compute`; core surface; binding: `operation`)
- `flywheel_compute_release_all` (mutating; scopes: `compute`; core surface; binding: `operation`)

### Contract, audit, and export

- `flywheel_get_contract` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_get_contract_section` (read; scopes: `read`; core surface; binding: `operation`)
- `flywheel_export_subgraph` (read; scopes: `read`; full-surface only; binding: `operation`)
- `flywheel_import_subgraph` (mutating; scopes: `write`; full-surface only; binding: `operation`)
- `flywheel_summarize_node_tree` (read; scopes: `read`; full-surface only; binding: `operation`)
- `flywheel_export_summary` (read; scopes: `read`; full-surface only; binding: `operation`)
- `flywheel_export_summary_stream` (read; scopes: `read`; full-surface only; binding: `operation`)
- `flywheel_export_summary_pdf` (read; scopes: `read`; full-surface only; binding: `operation`)
- `flywheel_export_summary_render_pdf` (read; scopes: `read`; full-surface only; binding: `operation`)

## HTTP Surface

### Discovery and sharing

- `GET /auth/status` -> `flywheel_auth_status`
- `GET /credits` -> `flywheel_get_credits_balance`
- `tool-mediated` -> `flywheel_updates_list`
- `POST /updates/{announcement_id}/hide` -> `flywheel_updates_hide`
- `POST /updates/hide-all-active` -> `flywheel_updates_hide_all_active`
- `DELETE /updates/{announcement_id}/hide` -> `flywheel_updates_unhide`
- `GET /nodes` -> `flywheel_list_nodes`
- `GET /nodes/resolve-by-slug` -> `flywheel_resolve_node_slug`
- `tool-mediated` -> `flywheel_get_node_sharing`
- `tool-mediated` -> `flywheel_set_sharing_for_node`
- `POST /nodes/access-policy/bulk` -> `flywheel_set_sharing_for_nodes`
- `tool-mediated` -> `flywheel_get_node`
- `POST /nodes/{root_node_id}/tags` -> `flywheel_create_node_tag`
- `PATCH /nodes/{root_node_id}/tags/{tag_id}` -> `flywheel_update_node_tag`
- `DELETE /nodes/{root_node_id}/tags/{tag_id}` -> `flywheel_delete_node_tag`
- `PUT /nodes/{node_id}/tags` -> `flywheel_set_node_tag_assignments`
- `GET /nodes/{node_id}/tree` -> `flywheel_get_node_tree`
- `GET /nodes/{node_id}/ancestry` -> `flywheel_get_node_ancestry`
- `GET /nodes/{node_id}/campaign/snapshot` -> `flywheel_get_campaign_snapshot`
- `GET /nodes/{node_id}/audit` -> `flywheel_list_audit`

### Node stage and commit

- `POST /nodes/commit-new` -> `flywheel_commit_new_node`
- `POST /nodes/{node_id}/stage/lease/acquire` -> `flywheel_acquire_stage_lease`
- `POST /nodes/{node_id}/stage/lease/heartbeat` -> `flywheel_heartbeat_stage_lease`
- `POST /nodes/{node_id}/stage/lease/release` -> `flywheel_release_stage_lease`
- `POST /nodes/{node_id}/commit` -> `flywheel_commit_node`
- `POST /nodes/{node_id}/branch` -> `flywheel_branch_node`
- `POST /nodes/merge` -> `flywheel_merge_nodes`
- `POST /nodes/{node_id}/parents/add` -> `flywheel_add_parent`
- `POST /nodes/{node_id}/parents/remove` -> `flywheel_remove_parent`
- `DELETE /nodes/{node_id}` -> `flywheel_delete_node`
- `POST /nodes/bulk-delete` -> `flywheel_bulk_delete_nodes`

### Artifacts

- `POST /nodes/{node_id}/artifacts/uploads/prepare` -> `flywheel_prepare_artifact_uploads`
- `POST /nodes/{node_id}/artifacts/uploads/finalize` -> `flywheel_finalize_artifact_uploads`
- `tool-mediated` -> `flywheel_list_artifacts`
- `tool-mediated` -> `flywheel_get_artifact`
- `DELETE /nodes/{node_id}/artifacts/{artifact_id}` -> `flywheel_delete_artifact`
- `POST /nodes/{node_id}/artifacts/bulk-delete` -> `flywheel_bulk_delete_artifacts`
- `PATCH /nodes/{node_id}/artifacts/{artifact_id}/note` -> `flywheel_set_artifact_note`

### Executions

- `POST /nodes/{node_id}/executions` -> `flywheel_launch_execution`
- `GET /nodes/{node_id}/executions` -> `flywheel_list_executions`
- `POST /nodes/{node_id}/executions/{execution_id}/terminate` -> `flywheel_terminate_execution`

### Compute and budgets

- `GET /compute/catalog` -> `flywheel_compute_list_options`
- `GET /compute/funding` -> `flywheel_compute_funding`
- `GET /compute/status` -> `flywheel_compute_status`
- `GET /compute/connection` -> `flywheel_compute_connection`
- `tool-mediated` -> `flywheel_approval_session_open`
- `POST /approval-sessions/heartbeat` -> `flywheel_approval_session_heartbeat`
- `GET /approval-sessions` -> `flywheel_list_approval_sessions`
- `POST /approval-sessions/expire` -> `flywheel_expire_approval_session`
- `tool-mediated` -> `flywheel_request_compute_grant_approval`
- `GET /compute/grants` -> `flywheel_list_compute_grants`
- `GET /nodes/{root_node_id}/campaign-budgets` -> `flywheel_list_campaign_budgets`
- `POST /nodes/{root_node_id}/campaign-budgets` -> `flywheel_create_campaign_budget`
- `PATCH /nodes/{root_node_id}/campaign-budgets/{compute_budget_id}` -> `flywheel_update_campaign_budget`
- `DELETE /nodes/{root_node_id}/campaign-budgets/{compute_budget_id}` -> `flywheel_revoke_campaign_budget`
- `tool-mediated` -> `flywheel_compute_acquire`
- `tool-mediated` -> `flywheel_compute_release`
- `tool-mediated` -> `flywheel_compute_release_all`

### Contract, audit, and export

- `GET /mcp/contract` -> `flywheel_get_contract`
- `GET /mcp/contract/sections/{section_id}` -> `flywheel_get_contract_section`
- `POST /export` -> `flywheel_export_subgraph`
- `POST /import` -> `flywheel_import_subgraph`
- `GET /nodes/{node_id}/summary` -> `flywheel_summarize_node_tree`
- `POST /export-summary` -> `flywheel_export_summary`
- `POST /export-summary-stream` -> `flywheel_export_summary_stream`
- `POST /export-summary-pdf` -> `flywheel_export_summary_pdf`
- `POST /export-summary-render-pdf` -> `flywheel_export_summary_render_pdf`

## Auth and Write Safety

- Available scopes: `read`, `write`, `compute`.
- Default grant scopes: `read`, `write`, `compute`.
- Transport-required scopes: `read`.
- Optimistic locking field: `expected_revision`.
- Conflict status code: `409`.
- Mutating HTTP calls require `Idempotency-Key`: `True`.
- MCP tool transport manages idempotency keys for mutating calls: `True`.
