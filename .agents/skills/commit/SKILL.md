---
name: commit
description: Create git commits from the current working directory with a bias toward small, coherent batches and single-line commit messages. Use when asked to commit work, make atomic commits, split changes into logical commits, or checkpoint local changes without interactive hunk staging.
---

# Commit

## Overview

Create commits directly from the working tree by grouping related files into the smallest practical units.
Prefer self-contained commits, but do not block on perfect separation when it would require slow interactive patching.

## Workflow

1. Inspect the working tree.
- Run `git status --short` and `git diff --name-only` (plus `git diff --staged` when needed).
- Identify logical groups by intent (fix, feature slice, refactor, docs, tests).

2. Stage one logical group at a time.
- Prefer staging whole files with `git add <paths>`.
- Do not default to `git add -p`; use patch mode only when explicitly requested.
- If a perfect split requires patch mode or excessive effort, group related changes and continue.

3. Commit with a single-line message.
- Use `git commit -m "<message>"`.
- Keep the message imperative and specific (`Add`, `Fix`, `Refactor`, `Update`, `Remove`).
- Keep it to one line; do not add a body unless explicitly asked.

4. Repeat until done.
- Re-check with `git status --short` after each commit.
- Continue committing remaining logical groups until no intended changes remain.

## Message Guidelines

- Prefer 4-10 words.
- Mention scope/object, not process noise.
- Avoid trailing punctuation.
- Avoid prefixes/suffixes unless repo conventions or user request require them.
- Examples: `Fix run status merge logic`, `Add retry handling for webhook sync`.

## Command Pattern

```bash
git status --short
git diff --name-only
git add path/to/file_a path/to/file_b
git commit -m "Fix run status merge logic"
git status --short
```

## Guardrails

- Never rewrite history (`--amend`, rebase, force-push) unless explicitly requested.
- Leave uncertain files unstaged and mention them rather than guessing.
- Exclude unrelated changes from a commit when practical.
