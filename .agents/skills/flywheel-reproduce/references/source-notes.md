# Notes Source Reference

Use this reference for local note directories such as Obsidian vaults, Logseq exports, or plain markdown note trees.

## Source Detection

Match this reference when source is a local notes corpus with many small markdown files.

## Acquisition

- Enumerate note files in requested scope.
- Preserve folder and filename context.

## Decomposition

- Default: one note file -> one node.
- Large note files: split by top-level headings when useful.
- Complete decomposition before creating validation branches.

## Content and Artifacts

- Note text in `content`.
- Concise note synopsis in `summary`.
- Embedded local files become artifacts when relevant.

## Edges

- Add edges only for durable relationships (hierarchy, prerequisite, dependency).
- Keep casual backlinks inside markdown.

## Failure Behavior

- If note files cannot be read, emit explicit failure with affected paths.

These rules apply only when `$flywheel-reproduce` is the active skill.
