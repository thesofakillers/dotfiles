# Generic Source Reference

Use this fallback when source type cannot be confidently matched to paper, wiki, blog, or notes.

## Fallback Trigger

Activate this reference only after deterministic and natural-language routing fail to produce a confident match.

## Acquisition

- Ask once for missing source location when not recoverable.
- Perform best-effort extraction from the provided source.

## Decomposition

- If top-level headings are available, create parent and section children.
- If no structural cues are available, create one node with explicit summary of limitations.
- Complete source decomposition before any validation branch planning.

## Content and Artifacts

- Keep extracted narrative in `content`.
- Attach supporting files as artifacts.

## Failure Behavior

- If extraction fails, emit explicit failure and stop.
- Do not silently produce an underspecified graph.

These rules apply only when `$flywheel-reproduce` is the active skill.
