---
name: flywheel-prove
description: Local Lean theorem proving and formalization pipeline.
---

# flywheel-prove

## When To Use

Use this skill when you need to scaffold or run a local Lean theorem proving pipeline in a repo.
Use it for formalization tasks that require filling `sorry` placeholders and proving statements in Lean.
Use it when converting theorem-heavy source material into Lean modules, iterating on failed verification, or producing reproducible proof artifacts for review.

## Modes

This skill is local-first, but install mode still defines how adjacent Flywheel routing behaves:

- **`--mode mcp` install**: no direct impact on the Lean proof workflow in this file.
- **`--mode cli` install**: `setup --mode cli` configures runtime credentials; prerequisite for bare-binary routing is the curl installer with `--mode cli` or the managed-prefix npm install recipe from the README.

When switching an already-configured host between modes, rerun setup with `--force` (or uninstall first) so prior-mode artifacts are reconciled explicitly.

## Prerequisite (Required)

As the very first thing, you MUST use the plan tool to create a task list with checkmarks for all the workflow steps that follow.

- If you are a codex model, use `update_plan`.
- If you are a claude model, use `TaskCreate`.
- If you are another model/harness, use an equivalent.

Include the following pre-requisite in the checkmark list.

Before running the pipeline, ensure both `uv` and the Lean toolchain manager `elan` are installed on the local machine.

- If `uv` is missing, bootstrap it by OS:
  - macOS/Linux:
    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```
  - Windows (PowerShell):
    ```powershell
    irm https://astral.sh/uv/install.ps1 | iex
    ```

- If `elan` is missing, bootstrap it by OS:
  - macOS/Linux:
    ```bash
    curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
    ```
  - Windows (PowerShell):
    ```powershell
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/leanprover/elan/master/elan-init.ps1 -OutFile elan-init.ps1
    powershell -ExecutionPolicy Bypass -File .\elan-init.ps1
    ```

Then verify:

```bash
uv --version
elan --version
lean --version
lake --version
```

## Workflow

1. Scaffold pipeline into the current repository:

   ```bash
   python <skill-root>/scripts/scaffold_pipeline.py --repo-root <repo-root> --setup-env
   cd <repo-root>/theorem_pipeline
   ```

   `<skill-root>` is the directory that contains this `SKILL.md`.
   `pypdf` is installed via template dependencies during `uv sync`; do not use `pdftotext`.

2. Move into `<repo-root>/theorem_pipeline` and initialize:

   ```bash
   uv run -m tproof.cli doctor
   uv run -m tproof.cli init --build
   ```

   Warning: `init --build` may take a few minutes on first run (toolchain/dependency fetch + first build). It is typically much faster on later runs when proving multiple artifacts in the same workspace.
   Requirement: Before executing `uv run -m tproof.cli init --build`, the agent MUST explicitly warn the human user in-chat about this first-run delay.

3. Normalize source context before formalization (conditional by input type).
   - First, identify the source type from the user request.
   - If the source is a PDF:
     - Extract text with `pypdf` (do not use `pdftotext`), enforce UTF-8-safe output, and sanitize mojibake.
     - Required artifact A (full cached extraction):
       - `theorem_pipeline/workspace/contexts/<pdf_stem>.txt`
       - Example: `paper.pdf -> theorem_pipeline/workspace/contexts/paper.txt`
     - Required artifact B (theorem-focused excerpt):
       - `theorem_pipeline/workspace/contexts/<theorem_slug>_source_excerpt.txt`
       - Example: `proposition2_source_excerpt.txt`
     - Keep both artifacts. The full extraction is a reusable cache for proving multiple theorems from the same paper; do not reconvert the PDF if the cached full extraction already exists and is still valid.
   - If the source is not a PDF (for example: prompt text, `.txt`, `.md`, `.tex`, or fetched online content):
     - Skip PDF conversion.
     - Use the source exactly as requested by the user.
     - Store the normalized local source artifact under `theorem_pipeline/workspace/contexts/` (for example, `<theorem_slug>_source.txt`), and optionally store a focused excerpt as `<theorem_slug>_source_excerpt.txt` when useful.
   - Explicit ASCII rewrites of common symbols are allowed (for example: `R-field -> Real`, `norm-notation -> norm x`, `leq -> <=`, `and -> /\\`, `arrow -> ->`).

4. Start a run:

   ```bash
   uv run -m tproof.cli start-run --prompt-file ./workspace/prompts/fill_sorries.txt
   ```

5. Formalization contract (required before proving): define
   - theorem name,
   - exact assumptions,
   - target conclusion,
   - whether corollaries are required (`help` / `match` / `upper-bound`).

6. Use required model routing:
   - Mathematical proof work: a deep-thinking model suitable for complex mathematical reasoning.
   - Programming/scripting/reporting work: a smaller coding-oriented model for automation and logs.

7. Artifact destination (mandatory, no exceptions):
   - Final theorem artifacts MUST live under:
     - `theorem_pipeline/workspace/lean_project/ProofWorkspace/Final/`
   - Never write final artifacts under `workspace/staging/` (forbidden).
   - Lean module files must use Lean-safe filenames (no hyphens), for example:
     - full formal proof file: `<Name>Full.lean`
     - human-readable sketch file: `<Name>Sketch.md`
     - example pair:
       - `ProofWorkspace/Final/Proposition1Full.lean`
       - `ProofWorkspace/Final/Proposition1Sketch.md`

8. Fast iteration loop:

   ```bash
   lake env lean <tmpfile>
   ```

   Use `<tmpfile>` for quick local iterations, then copy finalized proof into the target module.

9. Sidecar proof sketch (required):
   - For each produced full proof file `<Name>Full.lean`, create a sibling sketch file `<Name>Sketch.md` in `ProofWorkspace/Final/`.
   - Keep the sketch human-readable for paper-writing: theorem statement, assumptions, proof idea/structure, and how corollaries follow.
   - In sketch files, write mathematics using LaTeX formulas with dollar syntax (`$...$` for inline and `$$...$$` for display).
   - This is safe in the Lean project because the pipeline reindex/verification scans only `*.lean`.

10. Reindex and verify:

    ```bash
    uv run -m tproof.cli reindex
    uv run -m tproof.cli verify
    ```

    `verify` must pass with no unresolved `sorry` and no `.lean`/`.md` final artifacts under `workspace/staging/`.

11. Mark run status:

    ```bash
    uv run -m tproof.cli set-status <run_id> COMPLETE --note "verified locally"
    ```

## Completion Checklist

Always report:

- theorem file path,
- sidecar proof sketch path,
- final artifact directory path (`theorem_pipeline/workspace/lean_project/ProofWorkspace/Final/`),
- source context artifact path(s):
  - if PDF input: full extraction path (`<pdf_stem>.txt`) and excerpt path (`<theorem_slug>_source_excerpt.txt`);
  - otherwise: normalized source path used (for example `<theorem_slug>_source.txt`) and excerpt path if created,
- theorem names,
- verify log path,
- run id/status.
- Add one extra final report line (without changing existing format): `SUCCESS` or `FAIL: <reason>`.

## Resources

- Use `scripts/scaffold_pipeline.py` to install the full local pipeline template.
- Use `references/workflow.md` for detailed run loop guidance.
- Use `assets/pipeline_template/` as the canonical implementation source copied into each repository.
- Use `agents/interface.yaml` as the universal skill interface metadata.
