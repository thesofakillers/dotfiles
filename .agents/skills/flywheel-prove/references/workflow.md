# Workflow

## 0. Prerequisite: Local Toolchain Bootstrap

Ensure the host has:
- `uv`
- `elan` (Lean toolchain manager)

If `uv` is missing, install it by OS:
- macOS/Linux:
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```
- Windows (PowerShell):
  ```powershell
  irm https://astral.sh/uv/install.ps1 | iex
  ```

If `elan` is missing, install it by OS:
- macOS/Linux:
  ```bash
  curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
  ```
- Windows (PowerShell):
  ```powershell
  Invoke-WebRequest -Uri https://raw.githubusercontent.com/leanprover/elan/master/elan-init.ps1 -OutFile elan-init.ps1
  powershell -ExecutionPolicy Bypass -File .\elan-init.ps1
  ```

Verify bootstrap before running pipeline commands:

```bash
uv --version
elan --version
lean --version
lake --version
```

## 1. Scaffold Pipeline Into Repo

```bash
python <skill-root>/scripts/scaffold_pipeline.py --repo-root <repo-root> --setup-env
```

`<skill-root>` is the directory that contains this skill.

Creates `<repo-root>/theorem_pipeline` with:
- `workspace/lean_project/` canonical cumulative Lean project
- `data/runs/` run metadata and proof briefs
- `logs/` local Lean verification logs
- `src/tproof/` local CLI orchestration

## 2. Initialize Lean Toolchain

From `theorem_pipeline/`:

```bash
uv run -m tproof.cli doctor
uv run -m tproof.cli init --build
```

Warning: `init --build` can take several minutes the first time (toolchain/dependency download and initial compilation). Subsequent proving runs in the same workspace are usually much faster because those artifacts are cached.
Operator requirement: Before running `uv run -m tproof.cli init --build`, explicitly notify the human user in-chat about this first-run delay.

Pinned versions:
- Lean toolchain: `leanprover/lean4:v4.28.0`
- Mathlib hash: `8f9d9cff6bd728b17a24e163c9402775d9e6a365`

## 2.1 Source Context Normalization (Conditional)

Handle source ingestion based on user-provided input type.

If input is a PDF:
- Use `pypdf` (not `pdftotext`) and sanitize mojibake with UTF-8-safe output before theorem formalization.
- Required output A (full cached extraction):
  - `theorem_pipeline/workspace/contexts/<pdf_stem>.txt`
  - Example: `paper.pdf -> theorem_pipeline/workspace/contexts/paper.txt`
- Required output B (theorem-focused excerpt):
  - `theorem_pipeline/workspace/contexts/<theorem_slug>_source_excerpt.txt`
  - Example: `proposition2_source_excerpt.txt`
- Keep both outputs:
  - full extraction = reusable cache across multiple theorem proofs from the same paper;
  - excerpt = focused context for the current theorem.
- Reuse policy:
  - if the full extraction file already exists and is still valid for the current PDF, reuse it instead of converting the PDF again.

If input is not a PDF (prompt text, local `.txt`/`.md`/`.tex`, or fetched online source):
- Skip PDF conversion.
- Use the source as requested by the user.
- Store a normalized local source artifact under `theorem_pipeline/workspace/contexts/` (for example, `<theorem_slug>_source.txt`).
- Optionally store a focused excerpt as `<theorem_slug>_source_excerpt.txt` when useful for theorem-specific context.

ASCII rewrites of common symbols are allowed when needed for robust editing/parsing.

## 3. Create a Proof Run

```bash
uv run -m tproof.cli start-run --prompt-file ./workspace/prompts/fill_sorries.txt
```

This writes:
- `data/runs/<run_id>/run.json`
- `data/runs/<run_id>/run_brief.md`
- snapshot of the Lean project for traceability

## 4. Required Agent Routing

Use two workers:

1. Proof worker (math-heavy):
   - profile: deep-thinking reasoning model for complex mathematics
   - responsibility: theorem proving, decomposition, and difficult Lean proof terms.

2. Ops worker (programming/reporting):
   - profile: smaller coding-oriented model for implementation and reporting
   - responsibility: scripts, logs, verification loops, metadata updates, concise run reports.

## 5. Iterate Until Clean Verification

After proof edits:

```bash
uv run -m tproof.cli reindex
uv run -m tproof.cli verify
```

`verify` fails on:
- `lake build` failures
- any unresolved `sorry`
- any `.lean`/`.md` final artifacts found under `workspace/staging/` (forbidden; move to `ProofWorkspace/Final/`)

When done, set run status:

```bash
uv run -m tproof.cli set-status <run_id> COMPLETE --note "all goals proven and verified"
```

## 6. Final Artifact Placement and Sidecar Sketch Files (`.md`)

Final theorem artifacts must be written only under:
- `theorem_pipeline/workspace/lean_project/ProofWorkspace/Final/`

Forbidden output location:
- `workspace/staging/` for any final proof or sketch artifact.

For every finalized Lean proof file, create a sibling Markdown sketch file:
- Naming convention:
  - full proof (Lean-safe filename): `ProofWorkspace/Final/<Name>Full.lean`
  - sketch: `ProofWorkspace/Final/<Name>Sketch.md`
  - example pair: `ProofWorkspace/Final/Proposition1Full.lean` and `ProofWorkspace/Final/Proposition1Sketch.md`
- Keep sidecars in the same module directory so paper authors can trace them easily.
- In sketch files, all mathematics must be written with LaTeX dollar syntax (`$...$` / `$$...$$`).
- The `Proof Sketch` section must be fluent mathematical prose (paper style), not a numbered recipe.

Recommended sidecar template:

```md
# <Theorem Name>

## Statement
Plain-language statement mapped to the Lean theorem name(s).

## Assumptions
- A1
- A2
- ...

## Proof Sketch
Write a concise, fluent paragraph (or short sequence of paragraphs) as a mathematician would explain the proof to another mathematician in a paper. Emphasize the key reductions and ideas, but avoid low-level proof script details.

Use inline/display LaTeX where needed, for example:
`By reducing the claim to $X$, applying $Y$, and combining with $Z$, we obtain the target bound $f(x) \le g(x)$ for all $x \in D$.`

## Corollaries (if required)
- help
- match
- upper-bound

## Lean Artifacts
- File: <path/to/ProofWorkspace/Final/NameFull.lean>
- Theorems:
  - <theorem_name_1>
  - <theorem_name_2>
```

Compatibility note:
- The pipeline indexes/checks only `*.lean` files (`reindex`, module discovery, and `sorry` scan), so `.md` sidecars do not affect Lean verification.

## 7. Final Report Status Line

Keep the existing report format, and append one additional final line:
- `SUCCESS`
- or `FAIL: <reason>`
