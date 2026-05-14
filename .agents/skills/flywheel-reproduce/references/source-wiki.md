# Wiki Source Reference

Use this reference for markdown wiki-style corpora, README trees, GitHub wiki exports, and Notion markdown exports.

## Source Detection

Match this reference when source material is wiki-like markdown content with multiple linked pages.

## Acquisition

- Collect all relevant markdown pages in scope.
- Preserve stable page identifiers from file paths or page titles.

## Decomposition

- One stable page or concept maps to one node by default.
- Large pages may split by top-level headings when that improves readability.
- Complete graphification before branch planning and execution.

## Content and Artifacts

- Main narrative goes into node `content`.
- Short synopsis goes into `summary`.
- Supporting files (images, PDFs, data files, notebooks) are node artifacts.

## Edges

- Promote only durable semantic relationships to graph edges.
- Keep incidental hyperlinks in markdown body.

## Failure Behavior

- If pages are unreadable or missing, emit explicit failure and stop for that page.
- Do not silently skip unreadable pages.

These rules apply only when `$flywheel-reproduce` is the active skill.
