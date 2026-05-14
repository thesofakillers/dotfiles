# Blog Source Reference

Use this reference for blog posts and article-style URLs.

## Source Detection

Match this reference for sources from common blog/article domains or article-like HTML pages.

## Acquisition

- Fetch URL content.
- Extract main article body and heading structure.

## Decomposition

- Short posts: one node is acceptable.
- Long posts: parent article node plus section children by top-level headings.
- Complete source decomposition before branch planning.

## Content and Artifacts

- Article narrative in node `content`.
- Summary in `summary`.
- Supporting media files as artifacts when available.

## Edges

- Use hierarchy edges when section children are created.
- Avoid lateral interpretive edges by default.

## Failure Behavior

- If fetch or extraction fails, emit explicit failure and stop.

These rules apply only when `$flywheel-reproduce` is the active skill.
