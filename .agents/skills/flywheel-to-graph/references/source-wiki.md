# Wiki Source Reference

Use this reference for markdown wiki-style corpora, README trees, GitHub wiki exports, and Notion markdown exports.

## Source Detection

Match this reference when source material is wiki-like markdown content with multiple linked pages.

## Acquisition

- Collect all relevant markdown pages in scope.
- Preserve stable page identifiers from file paths or page titles.

## Decomposition

- One stable page or concept maps to one node by default.
- Large or operationally dense pages should split by concept, subsystem, procedure, policy, or contract boundary when that better captures the material than the page layout does.
- A wiki page is an anchor for discovery, not a mandatory final graph boundary.

## Content and Artifacts

- Main narrative goes into graph-native node `content`, including definitions, procedures, commands, configs, examples, and policy or contract detail when present.
- Paraphrase and reorganize when needed so the graph exposes the underlying system structure rather than the wiki's navigation structure.
- Short synopsis goes into `summary`.
- Supporting files (images, PDFs, data files, notebooks) are node artifacts.

## Edges

- Promote only durable semantic relationships to graph edges.
- Keep incidental hyperlinks in markdown body.

## Failure Behavior

- If pages are unreadable or missing, emit explicit failure and stop for that page.
- Do not silently skip unreadable pages.

These rules apply only when `$flywheel-to-graph` is the active skill.
