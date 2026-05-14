# Paper Source Reference

Use this reference when the source is a paper PDF, arXiv page, DOI URL, or direct PDF URL.

## Source Detection

Match this reference when any of these are true:

- Local file ends with `.pdf`.
- URL matches `arxiv.org/abs/`.
- URL matches `arxiv.org/pdf/`.
- URL is a DOI resolver link (`doi.org/...`).
- URL is a direct PDF link.

## Acquisition Rules

Acquire source content in this order:

1. Local PDF path: read local file bytes and preserve original filename.
2. arXiv HTML URL (`arxiv.org/abs/...` or `arxiv.org/html/...`): fetch page body and parse section structure from HTML.
3. arXiv PDF URL (`arxiv.org/pdf/...`): download PDF bytes and treat as PDF input.
4. DOI URL: resolve final landing page; if it exposes a PDF, download it, otherwise fetch the HTML body.
5. Direct PDF URL: download PDF bytes.

## Parsing Rules

For PDF text extraction, use parser fallback chain exactly:

`PyMuPDF -> pypdfium2 -> pypdf`

- Try one parser at a time in that order.
- Advance to the next parser only when the previous parser fails to extract usable text.
- If all parsers fail, emit explicit failure and stop. Do not continue with partial guessed structure.
- If all parsers fail, do not silently produce a single-summary node with a PDF artifact.

License note:

- PyMuPDF is AGPL-3.0. Artifex offers a commercial license when AGPL terms are not acceptable for downstream distribution.

For arXiv HTML parsing, use LaTeXML selector boundaries:

- Top-level sections: `section.ltx_section`
- Top-level headings: `h2.ltx_title`
- Subsections: `section.ltx_subsection`
- Subsection headings: `h3.ltx_title`

Do not use naive `section` selectors without class filtering.

## Graph Decomposition Contract

Default shape:

- Create one parent paper node under the requested root.
- Create one child node per detected top-level paper section only as a starting scaffold.
- If the paper's real structure is better captured by techniques, datasets, baselines, metrics, ablations, claims, or results, create those nodes even when they cut across the original section layout.
- If a top-level section is long or technically dense, add subsection or concept children until each node can hold graph-native content without collapsing into outline bullets.
- Typical section set includes Abstract, Introduction, Methods, Results, Discussion, Conclusion, and Related Work when present.

## Content Placement Contract

- Parent title: paper title.
- Parent summary: abstract or concise abstract-derived synopsis.
- Parent content: one-paragraph orientation to the paper's problem, approach, and main findings plus links/references to important child nodes.
- Child content: paraphrased technical substance for that unit, with enough detail to preserve the paper's problem framing, method, datasets, metrics, results, limitations, and key equations or procedures where present.
- Prefer concept-first paraphrase over paper-like prose restatement.
- Do not reduce Methods, Experiments, Results, or Appendices to short descriptive blurbs when the paper contains actionable technical detail there.
- Do not assume paper section names are the best final graph shape when regrouping by method component or evaluation logic is clearer.

## Artifact Contract

- Attach the paper PDF artifact to the parent paper node.
- Attach extracted figures/tables to the section child where they appear, when extraction is feasible.

## Edge Contract

- Use hierarchy edges for paper parent -> section children.
- Do not add lateral interpretive edges (`cites`, `builds-on`, `derived-from`) by default.

## Insight Controller Contract

- Single-paper one-shot import: no separate insight control node is created.
- Multi-paper corpus import: create one insight control node above paper parent nodes.

## Failure Contract

- If acquisition fails, return explicit failure with the failing source variant and stop.
- If all parsers fail, return explicit failure and stop.
- Do not silently degrade to one summary node plus artifact-only output.
- Do not silently collapse a technically dense paper into thin section stubs that cannot preserve the original argument, method, or evidence chain.

These rules apply only when `$flywheel-to-graph` is the active skill.
