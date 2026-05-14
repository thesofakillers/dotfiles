# Notes Source Reference

Use this reference for local note directories such as Obsidian vaults, Logseq exports, or plain markdown note trees.

## Source Detection

Match this reference when source is a local notes corpus with many small markdown files.

## Acquisition

- Enumerate note files in requested scope.
- Preserve folder and filename context.

## Decomposition

- Default: one note file -> one node.
- Large or detail-dense note files: cluster into decision, task, procedure, concept, or open-question nodes rather than following headings mechanically.

## Content and Artifacts

- Preserve concrete operational detail in graph-native `content`, including commands, paths, parameters, decision rationale, open questions, and TODO state when present.
- Prefer synthesis over raw note-dump copying when multiple notes express the same idea or workflow.
- Concise note synopsis in `summary`.
- Embedded local files become artifacts when relevant.

## Edges

- Add edges only for durable relationships (hierarchy, prerequisite, dependency).
- Keep casual backlinks inside markdown.

## Failure Behavior

- If note files cannot be read, emit explicit failure with affected paths.

These rules apply only when `$flywheel-to-graph` is the active skill.
