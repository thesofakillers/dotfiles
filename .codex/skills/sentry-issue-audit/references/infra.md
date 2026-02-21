# Infra Context Reference

## Secrets loading

Load secrets without printing values:

```bash
set -a
source ~/.secrets
set +a
```

## Fly.io apps

Production app:

```text
paradigma-flywheel
```

Staging app:

```text
paradigma-flywheel-staging
```

Inspect logs:

```bash
flyctl logs -a paradigma-flywheel
flyctl logs -a paradigma-flywheel-staging
```

Verify Sentry DSN secret:

```bash
flyctl secrets list -a paradigma-flywheel | rg SENTRY_DSN
flyctl secrets list -a paradigma-flywheel-staging | rg SENTRY_DSN
```

## Supabase / Postgres access

Use `psql` with the URLs from `~/.secrets`. Prefer read-only access for prod.

```bash
psql "$DATABASE_URL"
PGOPTIONS="--default_transaction_read_only=on" psql "$PROD_DATABASE_URL"
```

Supabase CLI is available for deeper inspection if needed:

```bash
supabase db --help
```
