# Flywheel Artifacts

Canonical artifact upload/finalize contract derived from `mcp_contract.py`.

## Upload Contract

- Prepare tool: `flywheel_prepare_artifact_uploads`.
- Finalize tool: `flywheel_finalize_artifact_uploads`.
- Raw file upload required between prepare/finalize: `True`.
- Upload transport step: `PUT` to `prepare.items[].upload_url`.
- Required headers source: `prepare.items[].upload_headers`.
- Upload body contract: `raw_file_bytes`.
- Prepare item required fields: `artifact_type`, `filename`, `media_type`.
- Prepare item optional fields: `title`, `execution_id`, `metadata`, `note`.
- Prepare item note: prepare.items[] is structured object input. The transport layer may tolerate stringified JSON as a compatibility measure; this tolerance is not contractual and may be removed.
- Raw upload stage success code: `202`.
- Stage semantics: `accepted_and_staged`.
- Finalize appends the batch with a single revision bump: `True`.
- Forbidden upload payload kinds: `json_metadata_wrapper`.
- Optional note field `note` applies to `artifact_metadata_record` (markdown allowed: `True`).

## Supported Artifact Types

- `text`, `table`, `json`, `image`, `banner`, `html`, `plotly_html`, `vega`, `checkpoint`, `binary`, `diff_carousel`

## Metadata Contract

- `title` required non-empty: `True`.
- Display label field: `title`.
- Title normalization priority: `explicit_title` -> `payload.title` -> `payload.name` -> `basename(payload.path|payload.filename|payload.file)` -> `basename(filename)` -> `basename(storage_path)` -> `artifact_type` -> `artifact`.
- Title must not derive from: `storage_url`.
- `storage_url` purpose: `raw_artifact_byte_read_url`.
- `storage_url` cannot be used as display label: `True`.

## Preview and Read Contract

- `flywheel_list_artifacts`: List node artifacts.
- `flywheel_get_artifact`: Get one artifact by id.
- No dedicated artifact preview tool exists in the current MCP operation catalog.
- Guidance: use flywheel_prepare_artifact_uploads, raw-file upload, and flywheel_finalize_artifact_uploads to publish experiment evidence before empirical completed commits

## Failure Causes to Handle Explicitly

- Stale `expected_revision` on mutating calls returns `409` and requires explicit reconciliation.
- Reusing an idempotency key with a different payload hash causes `409_conflict`.
- Prepare item payloads must be structured objects; stringified JSON item payloads are invalid.
- Uploading metadata wrappers instead of raw file bytes violates the upload contract.
- Finalize requires a valid prepared batch token and staged uploads from that batch.
