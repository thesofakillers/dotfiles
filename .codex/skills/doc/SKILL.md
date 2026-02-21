---
name: doc
description: Maintain repository documentation so it stays aligned with the current codebase and behavior. Use when tasks change APIs, architecture, workflows, scripts, configuration, runbooks, onboarding steps, or feature behavior and docs may need to be updated, newly created, reorganized, or deleted as stale.
---

# Doc

## Overview

Keep docs synchronized with the real system state. Prefer updating existing docs first, create new docs when no canonical location exists, and remove stale docs when they no longer describe live behavior.

## Workflow

1. Gather context.
- Read the active request and changed files (`git status --short`, `git diff --name-only`).
- Read existing documentation likely in scope (`README.md`, `docs/`, `project/*/README.md`, `AGENTS.md`).
- Identify behavior, interfaces, commands, paths, or policies that changed.

2. Map code changes to documentation surfaces.
- For each meaningful change, identify where it should be documented.
- Prefer canonical docs over duplicate notes.
- Reuse existing sections when possible before creating new files.

3. Choose the right action for each documentation gap.
- `Update` when the topic exists but is inaccurate, incomplete, or outdated.
- `Create` when the topic is new and no existing doc is a good fit.
- `Delete` when content is obsolete and has no remaining valid target.

4. Apply edits with minimal churn.
- Keep terminology consistent with the code and current architecture.
- Use concrete commands, paths, and prerequisites.
- Remove or rewrite stale steps instead of layering contradictory notes.
- Keep tone and structure aligned with nearby docs.

5. Validate documentation integrity.
- Search for stale names, file paths, commands, and old terminology with `rg`.
- If deleting docs, update incoming references in the same change.
- Run repo-required doc checks (for example `prettier`/`markdownlint`) when applicable.

6. Summarize outcomes.
- List files updated, created, and deleted.
- Explain the rationale in terms of current system behavior.
- Call out uncertain deletions or policy-sensitive edits if user confirmation is needed.

## Deletion Guardrails

- Delete only when evidence shows the subject is no longer current (removed feature, renamed system with migrated docs, dead workflow, or duplicated stale file).
- Prefer consolidation into a canonical doc over deleting information that is still relevant.
- Before deleting, verify references with `rg '<doc-name-or-topic>'` and patch those references.
- If uncertainty remains, keep the file and mark it for follow-up rather than deleting blindly.

## Command Pattern

```bash
git status --short
git diff --name-only
rg --files README.md docs project | head
rg "old-term|old-path|deprecated-command" README.md docs project
```

Use additional repo-specific validation commands after edits.
