# Sentry CLI + API Reference

## Auth and config

- Load `SENTRY_AUTH_TOKEN` from `~/.secrets` before running any commands.
- Use `SENTRY_URL` only if you are on a self-hosted Sentry instance. Default is `https://sentry.io`.

## CLI basics

Verify auth:

```bash
sentry-cli info
```

List orgs and projects:

```bash
sentry-cli organizations list
sentry-cli projects list -o <org_slug>
```

List unresolved issues:

```bash
sentry-cli issues list -o <org_slug> -p <project_slug> --query "is:unresolved" --max-rows 20
```

Filter a specific issue ID:

```bash
sentry-cli issues list -o <org_slug> -p <project_slug> -i <issue_id>
```

Search query examples (use Sentry search syntax):

```text
is:unresolved
environment:production
level:error
```

## REST API basics

Base URL:

```text
${SENTRY_URL:-https://sentry.io}/api/0
```

List issues by query:

```bash
SENTRY_URL="${SENTRY_URL:-https://sentry.io}"
curl -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  "$SENTRY_URL/api/0/organizations/<org_slug>/issues/?query=is:unresolved&limit=20"
```

Fetch issue details:

```bash
SENTRY_URL="${SENTRY_URL:-https://sentry.io}"
curl -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  "$SENTRY_URL/api/0/issues/<issue_id>/"
```

Fetch issue events:

```bash
SENTRY_URL="${SENTRY_URL:-https://sentry.io}"
curl -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  "$SENTRY_URL/api/0/issues/<issue_id>/events/"
```
