# Codex Setup and State Layout

This document is the source of truth for Codex setup on machines managed by
this dotfiles repository, including `paradevbox`.

## The Non-Negotiable Rule

There are two different `.codex` directories. They have different owners and
must never be collapsed into one directory:

```text
dotfiles repository                              user runtime home
<dotfiles>/.codex/                               ~/.codex/
├── AGENTS.md  ────────────────────────────────> AGENTS.md  (symlink)
├── config.toml ───────────────────────────────> config.toml (symlink)
└── (no authored skills here)

                                                   auth.json
                                                   sessions/
                                                   archived_sessions/
                                                   state_*.sqlite
                                                   logs_*.sqlite
                                                   plugins/
                                                   cache/
                                                   worktrees/
                                                   repair-backups/

<dotfiles>/.agents/                  <---------- ~/.agents/ (symlink)
└── skills/
    ├── linear-status/
    └── other personal skills/
```

The `.codex` arrows are individual symlinks created by
`.scripts/setup-codex-home`. The directory `~/.codex` itself is a real
directory. The separate `~/.agents` directory is intentionally a dotfiles
symlink because it contains portable authored skills, not Codex runtime state.

In one sentence:

> Git-tracked Codex configuration lives in `<dotfiles>/.codex` and is linked
> file-by-file into a real `~/.codex`, while all mutable Codex runtime state
> stays directly inside `~/.codex`. Authored global skills live under
> `<dotfiles>/.agents/skills` and appear to Codex as `~/.agents/skills`.

This follows the official OpenAI model: Codex stores per-user state under
`CODEX_HOME`, which defaults to `~/.codex`, and managed worktrees default to
`$CODEX_HOME/worktrees`.

## Never Do These Things

Do not:

- symlink the whole `~/.codex` directory to `<dotfiles>/.codex`;
- author standalone skills under `<dotfiles>/.codex/skills`; use
  `<dotfiles>/.agents/skills` instead;
- export `CODEX_HOME=<dotfiles>/.codex` in shell, SSH, launchd, or terminal
  configuration;
- put `sessions/`, SQLite databases, logs, caches, plugins, or worktrees in the
  dotfiles repository;
- copy or move Codex SQLite databases while the desktop app, CLI, or remote
  app-server is running;
- run `setup-codex-home --force` as part of normal setup;
- delete Codex runtime files to make `git status` or the layout check clean.

The specifically forbidden layout is:

```text
~/.codex -> <dotfiles>/.codex
```

That gives the same session and worktree two path spellings. Codex persists
absolute rollout and working-directory paths, so later migrations can produce
errors such as `no rollout found`, failed worktree-status checks, or tasks that
disappear after an app-server restart.

## What Goes Where

| Data | Canonical location | Git-tracked? | Notes |
| --- | --- | --- | --- |
| Personal Codex config source | `<dotfiles>/.codex/config.toml` | Yes | Linked into `~/.codex/config.toml` |
| Personal Codex instructions | `<dotfiles>/.codex/AGENTS.md` | Yes | Linked into `~/.codex/AGENTS.md` |
| Authored personal skills | `<dotfiles>/.agents/skills/` | Yes | Globally visible through `~/.agents/skills/` |
| Third-party skills | `<dotfiles>/.agents/skills/` | Lockfile only | Generated copies are ignored; `skills-lock.json` makes them reproducible |
| Codex bundled/system skills | `~/.codex/skills/.system/` | No | Runtime-managed; never copy into the repository |
| Authentication | `~/.codex/auth.json` or OS keychain | No | Never commit credentials |
| Sessions and archives | `~/.codex/sessions/`, `~/.codex/archived_sessions/` | No | Chat rollout history |
| State databases | `~/.codex/*_*.sqlite*` | No | Do not edit while Codex is running |
| Plugins and caches | `~/.codex/plugins/`, `~/.codex/cache/` | No | Installer/runtime-owned |
| Managed worktrees | `~/.codex/worktrees/` | No | Default desktop-app worktree root |
| Migration backups | `~/.codex/repair-backups/`, `~/.dotfiles-backups/` | No | Keep until recovery is verified |

The dotfiles repository's `.codex` directory is the version-controlled source
for personal configuration on these machines. It is not `CODEX_HOME` and it is
not a valid place for mutable runtime state.

## Fresh Machine Setup

Do not launch Codex until all setup commands below complete.

```bash
git clone <your-dotfiles-repo-url> ~/repos/dotfiles
cd ~/repos/dotfiles
./bootstrap.sh
npx --yes skills experimental_install
./.scripts/setup-codex-home --check
```

Bootstrap links authored skills immediately. The Skills CLI command restores
the exact third-party skills recorded in `skills-lock.json`; their generated
directories are intentionally not committed.

Expected final output:

```text
[codex-home] layout is healthy: real runtime directory plus <N> managed config links and <N> global skills
```

Then launch or restart the Codex desktop app.

If this machine keeps the repository somewhere other than
`~/repos/dotfiles`, that is fine. The helper resolves the repository from its
own file location and creates symlinks to that absolute path.

## Updating an Existing Machine

For an ordinary dotfiles update where the layout is already healthy:

```bash
cd ~/repos/dotfiles
git pull --ff-only
./.scripts/setup-codex-home --check
```

Run `--apply` only when tracked `.codex` files changed, links are missing, or
the check reports a migration problem. Before `--apply`, fully quit the Codex
desktop app and close Codex CLI sessions:

```bash
cd ~/repos/dotfiles
./.scripts/setup-codex-home --apply
./.scripts/setup-codex-home --check
```

The helper intentionally refuses to modify state databases while Codex is
using them. `Codex is using its state databases` is a safety check, not a
setup failure. Quit Codex and retry.

## `paradevbox`

`paradevbox` uses the same layout:

```text
/Users/giulio/repos/dotfiles/.codex/  tracked configuration source
/Users/giulio/.codex/                real Codex runtime home
```

Read-only verification from another machine is safe:

```bash
ssh paradevbox \
  'cd ~/repos/dotfiles && ./.scripts/setup-codex-home --check'
```

For a repair or migration:

1. Quit or disconnect Codex clients using `paradevbox`.
2. Wait for the remote Codex app-server connection to close.
3. Run the helper from a normal SSH terminal.
4. Run `--check` before reconnecting Codex.

```bash
ssh paradevbox \
  'cd ~/repos/dotfiles && \
   ./.scripts/setup-codex-home --apply && \
   ./.scripts/setup-codex-home --check'
```

Do not set remote `CODEX_HOME` to
`/Users/giulio/repos/dotfiles/.codex`. Leave it unset so it defaults to
`/Users/giulio/.codex`.

## What `setup-codex-home` Does

`--check` is read-only. It verifies that:

- `~/.codex` is a real directory;
- every Git-tracked dotfiles `.codex` file has the expected symlink in
  `~/.codex`;
- `~/.agents` resolves to the repository `.agents` directory, making tracked
  and lockfile-restored skills globally discoverable;
- no authored skill remains in the legacy repository `.codex/skills` path;
- no user skill remains in the legacy runtime `~/.codex/skills` path (Codex's
  runtime-managed `.system` directory is allowed);
- the repository `.codex` directory contains no ignored or untracked runtime
  files;
- thread database rollout and working-directory paths do not point into the
  repository `.codex` directory;
- rollout metadata does not contain repository-prefixed worktree paths.

`--apply` additionally:

- migrates a legacy whole-directory symlink to the supported split layout;
- links tracked configuration files individually;
- moves non-conflicting runtime leftovers from the repository into the real
  Codex home;
- quarantines conflicting runtime leftovers under
  `~/.dotfiles-backups/` instead of overwriting either copy;
- backs up and normalizes affected SQLite state paths;
- backs up and normalizes affected rollout working-directory metadata;
- repairs Git worktree administrative paths after a move;
- migrates unique legacy user skills from `~/.codex/skills` into
  `<dotfiles>/.agents/skills` and backs up duplicate legacy entries under
  `~/.dotfiles-backups/`.

`--force` disables the active-process safety check. It does not make an unsafe
migration safe. Use it only for deliberate disaster recovery after separately
proving that no Codex process has the relevant files open.

## Manual Verification

From the dotfiles repository:

```bash
repo_root="$(git rev-parse --show-toplevel)"

test -d "$HOME/.codex"
test ! -L "$HOME/.codex"
test "$(readlink "$HOME/.codex/config.toml")" = \
  "$repo_root/.codex/config.toml"
test "$HOME/.agents" -ef "$repo_root/.agents"
test -r "$HOME/.agents/skills/linear-status/SKILL.md"
test -d "$HOME/.codex/worktrees"
./.scripts/setup-codex-home --check
```

Check the shell environment used to launch Codex:

```bash
printf 'CODEX_HOME=%s\n' "${CODEX_HOME-<unset>}"
```

Healthy output is either `<unset>` or the real runtime path, normally
`$HOME/.codex`. A path inside the dotfiles repository is wrong.

## Recovery Guide

### `~/.codex is still a whole-directory symlink`

Quit Codex, run `--apply`, then run `--check`.

### `repository .codex still contains runtime/untracked files`

If the check reports ignored files, a process probably wrote runtime state
using the repository as `CODEX_HOME`. Do not delete those files. Quit Codex and
run `--apply`. The helper moves ignored files that are missing from the real
runtime home and quarantines conflicting copies under
`~/.dotfiles-backups/`.

If the check reports non-ignored untracked files, the helper does not guess
whether they are new configuration or accidental output. Review them: commit
intentional configuration, or move accidental files to the correct owner.

### `repository-prefixed paths` or `rollouts with repository-prefixed cwd`

Quit Codex and run `--apply`. The helper creates repair backups before changing
SQLite rows or rollout metadata.

### `Codex is using its state databases`

Quit every local Codex desktop/CLI process using this home. For a remote host,
also disconnect remote Codex clients. Retry without `--force`.

### `no rollout found` or `Couldn't check worktree status`

1. Stop Codex on the affected host.
2. Run `setup-codex-home --check`.
3. If it reports path or runtime-state errors, run `--apply`.
4. Run `--check` again and require a healthy result.
5. Restart Codex and retry the task.

If the layout check is healthy but a single old worktree was already removed,
use the desktop app's restore option. Codex normally snapshots managed
worktrees before automatic cleanup.

### A personal skill is missing from some tasks

Personal skills must live under `<dotfiles>/.agents/skills`, and
`~/.agents` must resolve to `<dotfiles>/.agents`. A skill under either
`<dotfiles>/.codex/skills` or `~/.codex/skills` is in a legacy user-skill
location and may only appear in some cached or repository-specific task
catalogs. The helper rejects both legacy locations; `--apply` migrates runtime
legacy skills without deleting conflicting copies.

Run `setup-codex-home --check`, verify the skill manifest is readable through
`~/.agents/skills/<name>/SKILL.md`, and restart Codex only if an already-open
picker remains stale. Codex normally detects skill changes automatically.

For third-party skills, restore the exact locked versions from the dotfiles
root with `npx --yes skills experimental_install`. Do not commit the generated
vendor directories; commit `skills-lock.json`.

## Backups

The migration is designed to preserve recoverability:

- replaced tracked destinations go under
  `~/.dotfiles-backups/<timestamp>-codex-home/`;
- conflicting repository runtime files go under
  `~/.dotfiles-backups/<timestamp>-codex-repo-runtime-conflicts/`;
- SQLite backups and rollout first-line backups go under
  `~/.codex/repair-backups/`.

Do not remove these backups until tasks resume correctly and the layout check
passes on every configured Codex host.

## Official References

- [OpenAI Docs: config and state locations](https://learn.chatgpt.com/docs/config-file/config-advanced#config-and-state-locations)
- [OpenAI Docs: Git worktrees](https://learn.chatgpt.com/docs/environments/git-worktrees)
- [OpenAI Docs: build skills and local discovery](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills)
