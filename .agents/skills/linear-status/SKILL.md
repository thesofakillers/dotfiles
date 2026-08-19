---
name: linear-status
description: Fetch and format a fresh, dependency-aware view of the current user's Linear work. Use for requests such as “show my Linear status,” “list my active Linear tickets,” “refresh my unblocked Linear work,” or equivalent status reports across In Progress, In Review, Todo, Backlog, and On Hold.
---

# Linear Status

Produce a live read-only report. Never reuse ticket state from conversation history or a previous run.

## Fetch

1. List issues assigned to `me` separately for these exact statuses, following pagination through completion:
   1. In Progress
   2. In Review
   3. Todo
   4. Backlog
   5. On Hold
2. Fetch every returned issue directly with relations included. Use this fresh detail response for its current status, priority, due date, URL, and dependency relations.
3. Collect every unique issue referenced by `blockedBy` or `blocks`, then fetch each referenced issue directly. Do not infer dependency state from descriptions, comments, relation presence, or prior context.

## Filter

- Exclude assigned issues whose refreshed status is Done, Canceled, or Dropped.
- Treat a blocker as resolved only when its refreshed status is Done, Canceled, or Dropped.
- Hide an assigned issue when any refreshed `blockedBy` issue is not resolved.
- Treat an issue blocked by several dependencies as visible only when every blocker is resolved.
- Mark a visible issue with `🚧` when any refreshed issue in its `blocks` relations is active. Treat every status other than Done, Canceled, and Dropped as active.
- Do not mutate Linear unless the user separately and explicitly requests a mutation.

## Format

Begin with:

`Fetched **N** assigned tickets · Showing **N** · Hidden by unresolved blockers **N**`

Then:

- Group sections in this order: In Progress, In Review, Todo, Backlog, On Hold.
- Include every section, including zero-count sections.
- Sort each section by priority: Urgent, High, Medium, Low, No priority.
- Use `🔴` Urgent, `🟠` High, `🟡` Medium, `🟢` Low, and `⚪` No priority.
- Render each identifier as a clickable link to its Linear URL.
- Show the title and due date when present.
- For `🚧` issues, name the active tickets they block when concise; otherwise report the count.
- Keep hidden ticket details out of the report unless the user asks for them.

Use this line shape:

`- 🟡 [ABC-123](LINEAR_URL) — Ticket title · Due 15 Aug 2026 · 🚧 Blocks 4 active tickets`
