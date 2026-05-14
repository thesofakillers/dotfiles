# Blog Source Reference

Use this reference for blog posts and article-style URLs.

## Source Detection

Match this reference for sources from common blog/article domains or article-like HTML pages.

## Acquisition

- Fetch URL content.
- Extract main article body and heading structure.

## Decomposition

- Short posts: one node is acceptable only if that node still preserves the post's concrete substance.
- Long or technical posts: parent article node plus concept, procedure, API-surface, decision, or comparison children around the post's logical flow, not just its heading structure.

## Content and Artifacts

- Article narrative in graph-native `content`.
- Preserve concrete commands, code patterns, config, API shapes, examples, warnings, and caveats when present.
- Paraphrase the post's substance rather than copying blog prose, except where exact snippets matter.
- Summary in `summary`.
- Supporting media files as artifacts when available.

## Edges

- Use hierarchy edges when section children are created.
- Avoid lateral interpretive edges by default.

## Failure Behavior

- If fetch or extraction fails, emit explicit failure and stop.

These rules apply only when `$flywheel-to-graph` is the active skill.
