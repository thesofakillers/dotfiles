#!/usr/bin/env python3
"""
Scaffold a local Lean theorem proving pipeline into a target repository.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path


def run(command: list[str], cwd: Path) -> None:
    proc = subprocess.run(command, cwd=cwd, text=True, check=False)
    if proc.returncode != 0:
        raise RuntimeError(f"Command failed ({proc.returncode}): {' '.join(command)}")


def scaffold(repo_root: Path, subdir: str, force: bool) -> Path:
    skill_root = Path(__file__).resolve().parents[1]
    template_dir = skill_root / "assets" / "pipeline_template"
    if not template_dir.is_dir():
        raise FileNotFoundError(f"Missing template directory: {template_dir}")

    target = (repo_root / subdir).resolve()
    if target.exists():
        if not force:
            raise FileExistsError(
                f"Target already exists: {target}. Pass --force to replace it."
            )
        if target == repo_root.resolve():
            raise RuntimeError("Refusing to delete repo root.")
        shutil.rmtree(target)

    shutil.copytree(template_dir, target)
    return target


def ensure_uv_available() -> None:
    proc = subprocess.run(
        ["uv", "--version"], capture_output=True, text=True, check=False
    )
    if proc.returncode != 0:
        raise RuntimeError(
            "Missing `uv` on PATH. Install uv first: https://docs.astral.sh/uv/getting-started/installation/"
        )


def setup_env_with_uv(pipeline_dir: Path) -> None:
    ensure_uv_available()
    run(["uv", "sync"], cwd=pipeline_dir)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scaffold local Lean theorem proving pipeline."
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path.cwd(),
        help="Repository root where the pipeline folder will be created.",
    )
    parser.add_argument(
        "--subdir",
        type=str,
        default="theorem_pipeline",
        help="Subdirectory name for the pipeline workspace.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Replace target directory if it already exists.",
    )
    parser.add_argument(
        "--setup-env",
        action="store_true",
        help="Run `uv sync` in the scaffolded pipeline directory.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    repo_root.mkdir(parents=True, exist_ok=True)

    pipeline_dir = scaffold(repo_root=repo_root, subdir=args.subdir, force=args.force)
    if args.setup_env:
        setup_env_with_uv(pipeline_dir)

    print(f"[OK] Scaffolded pipeline at: {pipeline_dir}")
    print("Next commands:")
    print(f"  cd {pipeline_dir}")
    if not args.setup_env:
        print("  uv sync")
    print("  uv run -m tproof.cli doctor")
    print("  uv run -m tproof.cli init --build")
    print(
        "  uv run -m tproof.cli start-run --prompt-file ./workspace/prompts/fill_sorries.txt"
    )
    print("  uv run -m tproof.cli verify")
    print("Optional wrappers:")
    print("  macOS/Linux: ./bin/tproof doctor")
    print("  Windows cmd: .\\bin\\tproof.cmd doctor")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
