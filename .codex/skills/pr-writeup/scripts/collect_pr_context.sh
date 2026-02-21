#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: collect_pr_context.sh [--base <ref>] [--patch] [--unified <n>] [--max-commits <n>]

Print a Markdown context bundle for drafting a PR/MR writeup:
- repo + branch
- status (uncommitted changes)
- commits since merge-base
- diffstat + changed files
- optional patch (use --patch)

Run this from inside the target git repo.
EOF
}

base_ref=""
include_patch=0
unified=3
max_commits=50

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      base_ref="${2:-}"
      shift 2
      ;;
    --patch)
      include_patch=1
      shift
      ;;
    --unified)
      unified="${2:-}"
      shift 2
      ;;
    --max-commits)
      max_commits="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! command -v git >/dev/null 2>&1; then
  echo "git not found in PATH" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repo. cd into the repo and try again." >&2
  exit 1
fi

pick_default_base() {
  local candidate=""

  if git show-ref --verify --quiet refs/remotes/origin/HEAD; then
    candidate="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD || true)"
    if [[ -n "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  fi

  # Common default branches (remote first).
  if git show-ref --verify --quiet refs/remotes/origin/main; then
    echo "origin/main"
    return 0
  fi
  if git show-ref --verify --quiet refs/remotes/origin/master; then
    echo "origin/master"
    return 0
  fi
  if git show-ref --verify --quiet refs/remotes/origin/develop; then
    echo "origin/develop"
    return 0
  fi
  if git show-ref --verify --quiet refs/remotes/origin/dev; then
    echo "origin/dev"
    return 0
  fi
  if git show-ref --verify --quiet refs/heads/main; then
    echo "main"
    return 0
  fi
  if git show-ref --verify --quiet refs/heads/master; then
    echo "master"
    return 0
  fi
  if git show-ref --verify --quiet refs/heads/develop; then
    echo "develop"
    return 0
  fi
  if git show-ref --verify --quiet refs/heads/dev; then
    echo "dev"
    return 0
  fi

  echo ""
}

if [[ -z "$base_ref" ]]; then
  base_ref="$(pick_default_base)"
fi

branch="$(git branch --show-current || true)"
if [[ -z "$branch" ]]; then
  branch="(detached)"
fi

repo_root="$(git rev-parse --show-toplevel)"

base_commit=""
range=""
if [[ -n "$base_ref" ]]; then
  # Prefer --fork-point so rebases keep the original branch point when possible.
  base_commit="$(git merge-base --fork-point "$base_ref" HEAD 2>/dev/null || true)"
  if [[ -z "$base_commit" ]]; then
    base_commit="$(git merge-base "$base_ref" HEAD 2>/dev/null || true)"
  fi
fi

if [[ -n "$base_commit" ]]; then
  range="${base_commit}..HEAD"
fi

echo "## PR Context (auto-generated)"
echo "- Repo: \`$repo_root\`"
echo "- Branch: \`$branch\`"
if [[ -n "$base_ref" ]]; then
  echo "- Base ref: \`$base_ref\`"
else
  echo "- Base ref: (not detected; pass \`--base <ref>\`)"
fi
if [[ -n "$base_commit" ]]; then
  echo "- Base commit: \`$base_commit\`"
fi
echo

echo "### Status"
echo '```'
git status --porcelain=v1 || true
echo '```'
echo

if [[ -n "$range" ]]; then
  commit_count="$(git rev-list --count "$range" 2>/dev/null || true)"
  echo "### Commits (most recent; max ${max_commits})"
  if [[ "$commit_count" =~ ^[0-9]+$ ]] && [[ "$commit_count" -gt "$max_commits" ]]; then
    echo "> Note: showing ${max_commits} of ${commit_count} commits."
    echo
  fi
  echo '```'
  git log --oneline --max-count="$max_commits" "$range" || true
  echo '```'
  echo

  echo "### Diffstat"
  echo '```'
  git diff --stat "$range" || true
  echo '```'
  echo

  echo "### Changed files"
  echo '```'
  git diff --name-status "$range" || true
  echo '```'
  echo

  if [[ "$include_patch" -eq 1 ]]; then
    echo "### Patch (-U${unified})"
    echo '```diff'
    git diff "-U${unified}" "$range" || true
    echo '```'
    echo
  fi
else
  echo "> Note: Could not determine a merge-base range. Re-run with \`--base <ref>\`."
  echo
fi
