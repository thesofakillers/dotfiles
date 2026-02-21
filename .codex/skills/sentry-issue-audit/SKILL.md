---
name: sentry-issue-audit
description: Audit and triage Sentry issues for Flywheel/Fly.io apps using sentry-cli and the Sentry REST API. Use when asked to investigate a specific Sentry issue ID, audit or summarize the latest Sentry issues, or correlate Sentry errors with Fly.io logs or Supabase data using secrets from ~/.secrets (SENTRY_AUTH_TOKEN, database URLs, flyctl auth).
---

# Sentry Issue Audit

## Overview

- Audit Sentry issues via sentry-cli and the Sentry REST API.
- Load auth from ~/.secrets without exposing tokens.
- Correlate errors with Fly.io logs and Supabase data when needed.

## Quick Start

1. Load secrets into the shell:

   ```bash
   set -a
   source ~/.secrets
   set +a
   ```

2. Verify Sentry auth:

   ```bash
   sentry-cli info
   ```

3. Identify org and project slugs:

   ```bash
   sentry-cli organizations list
   sentry-cli projects list -o <org_slug>
   ```

4. Save org/project for reuse:

   ```bash
   export SENTRY_ORG="<org_slug>"
   export SENTRY_PROJECT="<project_slug>"
   ```

## Workflow

### Audit A Specific Issue ID

1. Confirm the issue exists:

   ```bash
   sentry-cli issues list -o "$SENTRY_ORG" -p "$SENTRY_PROJECT" -i "<issue_id>"
   ```

2. Pull full issue details and recent events via the REST API.
   See `references/sentry-cli.md` for curl examples and endpoints.

3. Summarize scope, frequency, last seen, environment, top stack frames,
   and suspected root cause.

### Audit The Latest Issues

1. List the latest unresolved issues:

   ```bash
   sentry-cli issues list -o "$SENTRY_ORG" -p "$SENTRY_PROJECT" --query "is:unresolved" --max-rows 20
   ```

2. Pick the target issue(s), then follow the specific issue workflow.
   If ordering matters, use the REST API to sort by `lastSeen`.

### General Audit And Summary

1. Build clusters from the latest issues (by title/fingerprint, service, or
   route) and list them in the summary.
2. If the user requests a sort order, honor it.
3. If the user does not specify, ask whether to sort by severity or date.
   If you cannot ask, default to severity (high to low), then by `lastSeen`.

### Correlate With Infra (Optional)

1. Inspect Fly.io logs for the matching timeframe.
2. Query Supabase with read-only SQL to confirm data anomalies.
   See `references/infra.md` for safe commands and app names.

## Output Template

Produce an audit summary with these sections:

- Issue: ID, title, project, environment
- Impact: first/last seen, event count, affected users
- Evidence: key stack trace frames, tags, sample events, relevant logs/queries
- Suspected root cause: concise hypothesis
- Recommended next steps: mitigations, fixes, owners
- Clusters: list grouped issues sorted by severity or date
- Format: avoid tables; use plain text lists for terminal readability

## Resources

- `references/sentry-cli.md` for CLI commands and REST API endpoints.
- `references/infra.md` for Fly.io and Supabase context.
