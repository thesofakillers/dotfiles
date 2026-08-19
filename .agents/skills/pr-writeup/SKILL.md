---
name: pr-writeup
description: Draft and polish pull request / merge request titles and descriptions (PR/MR writeups) by comparing commits on the current branch vs the base branch it diverged from. Use when asked for a PR/MR title, PR/MR description, or a writeup that summarizes a commit range/diff for reviewers. Includes a compact bugfix format (Symptom/Root cause/Fix/Prevention) and a separate feature format.
---

# PR Writeup

## Overview

Write PR/MR titles and short, structured descriptions from the commits on a branch compared to the base branch it was branched from. Output Markdown ready to paste into GitHub/GitLab.

## Workflow

### 1. Detect conventions (do this first)

- Look for a repo template and follow it if present.
  - GitHub: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`
  - GitLab: `.gitlab/merge_request_templates/`
- Check for title conventions (e.g., Conventional Commits `feat:`, `fix:` or `[area] ...`).
  - If unclear, infer from recent merge commit subjects and/or existing PR metadata in the repo (when available).

### 2. Determine the base and commit range (do not guess)

The base should be the branch this topic branch diverged from (often `origin/main` or `origin/master`). Prefer a fork-point/merge-base derived range over hand-waving.

Commands (typical; pick what you can run):

```bash
git status --porcelain=v1
git branch --show-current

# If you know the base ref, use fork-point if possible:
git merge-base --fork-point <base> HEAD || git merge-base <base> HEAD

# Then diff from that base commit:
git log --oneline <base_commit>..HEAD
git diff --stat <base_commit>..HEAD
git diff <base_commit>..HEAD
```

Optional helper (prints a Markdown context bundle): `scripts/collect_pr_context.sh` (run from the repo you are writing the PR for; supports `--base` and uses fork-point when available).

### 3. Decide the writeup type

If it is not explicit, ask one question: "Is this PR a bugfix or a feature?"

### 4. Ask for missing context (max 3 questions)

Only ask what you truly need to avoid making things up. Typical:

- What is the user-visible symptom or problem (and where did it show up)?
- What is the root cause (if known) and how confident are we?
- Any prevention / follow-up (tests, alerts, invariants, refactor)?

### 5. Draft the PR title

- Use imperative voice: "Add …", "Fix …", "Remove …".
- Prefer specificity over cleverness. Avoid internal jargon unless it is standard in the repo.
- Keep it short (aim ~50-72 chars) and do not add a trailing period.
- If conventions exist, follow them; otherwise, do not invent prefixes.
- If uncertain, provide 2-3 good options and label the recommended one.

### 6. Draft the PR description (keep it short)

- Use the relevant template below (Bugfix or Feature).
- Keep each section to at most one paragraph (ideally 2-4 sentences).
- Do not add extra sections for bugfixes unless the user asked.
- Avoid claiming anything you cannot justify from the commit range/diff or user-provided context.

### 7. Output in a paste-ready format

When the user asks for "a PR title/description", output exactly:

1. `Title:` line
2. `Description:` code fence containing GitHub/GitLab-flavored Markdown

## Templates

### Bugfix (requested format)

```markdown
## Symptom
<!-- What went wrong and how it manifested. One short paragraph. -->

## Root cause
<!-- The underlying reason. One short paragraph. -->

## Fix
<!-- What this PR changes to address it. One short paragraph. -->

## How we will avoid in the future
<!-- Tests, invariants, monitoring, process change, follow-up work. One short paragraph. -->
```

### Feature (flexible)

There is no fixed structure for features. Pick headings that match repo conventions and what reviewers need. Keep it short: at most a paragraph per section.

Example template (optional):

```markdown
## User problem / goal
<!-- What we are enabling and why. One short paragraph. -->

## Solution
<!-- High-level approach and what changed. One short paragraph. -->

## Notes / follow-ups
<!-- Tradeoffs, edge cases, future improvements, or rollout/testing notes. One short paragraph. -->
```

If the user wants a test plan included for features, add it as a single sentence inside one of the paragraphs (do not expand into long step lists unless requested).
```
