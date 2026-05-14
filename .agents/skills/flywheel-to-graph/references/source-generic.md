# Generic Source Reference

Use this fallback when source type cannot be confidently matched to paper, wiki, blog, or notes.

## Fallback Trigger

Activate this reference only after deterministic and natural-language routing fail to produce a confident match.

## Acquisition

- Ask once for missing source location when not recoverable.
- Perform best-effort extraction from the provided source.

## Decomposition

- If top-level headings are available, use them as hints, then regroup into concept, procedure, claim, result, comparison, or decision nodes as needed.
- If no structural cues are available, create thematic child nodes whenever possible instead of forcing one monolithic node.

## Content and Artifacts

- Keep extracted narrative in graph-native `content`, paraphrased unless exact wording matters.
- Attach supporting files as artifacts.

## Failure Behavior

- If extraction fails, emit explicit failure and stop.
- Do not silently produce an underspecified graph.

These rules apply only when `$flywheel-to-graph` is the active skill.
