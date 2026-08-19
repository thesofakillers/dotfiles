# Codex Dotfiles Layout

This is the source of truth for Codex configuration on machines using this
dotfiles repository, including `paradevbox`.

## The Boundary

Keep portable configuration separate from mutable runtime state:

```text
<dotfiles>/.codex/                 ~/.codex/
├── AGENTS.md  ------------------> AGENTS.md
└── config.toml -----------------> config.toml

<dotfiles>/.agents/ <------------ ~/.agents
└── skills/

                                  ~/.codex/auth.json
                                  ~/.codex/sessions/
                                  ~/.codex/plugins/
                                  ~/.codex/worktrees/
                                  ~/.codex/*_*.sqlite*
```

The arrows are symlinks. `~/.codex` itself is always a real directory.

In short:

- `<dotfiles>/.codex` contains Git-tracked Codex configuration.
- `~/.codex` is `CODEX_HOME` and contains Codex-owned runtime state.
- `<dotfiles>/.agents` contains portable skills and skill metadata.
- `~/.agents` links to `<dotfiles>/.agents` for user-wide skill discovery.

Never point `CODEX_HOME` at `<dotfiles>/.codex`, and never symlink the entire
`~/.codex` directory into the repository.

## Ownership

| Content | Location | Tracked? |
| --- | --- | --- |
| Personal Codex config source | `<dotfiles>/.codex/` | Yes |
| Authored personal skills | `<dotfiles>/.agents/skills/` | Yes |
| Third-party skill versions | `<dotfiles>/skills-lock.json` | Yes |
| Generated third-party skill copies | `<dotfiles>/.agents/skills/` | No |
| Auth, sessions, databases, plugins, caches, and worktrees | `~/.codex/` | No |
| Codex system skills | `~/.codex/skills/.system/` | No |

Do not add runtime files to the repository to make them portable. Codex owns
their format and lifecycle.

## Setup

On a fresh machine:

```bash
git clone <your-dotfiles-repo-url> ~/repos/dotfiles
cd ~/repos/dotfiles
./bootstrap.sh
npx --yes skills experimental_install
./.scripts/setup-codex-home --check
```

For an existing checkout:

```bash
git pull --ff-only
./.scripts/setup-codex-home --apply
./.scripts/setup-codex-home --check
```

Restart Codex only if an already-open client does not pick up a configuration
or skill change.

## The Helper

`.scripts/setup-codex-home --check` is read-only. It verifies:

- `~/.codex` is a real directory;
- each tracked file under `<dotfiles>/.codex` has the expected link under
  `~/.codex`;
- `~/.agents` resolves to `<dotfiles>/.agents`;
- authored skills are not stored in either legacy `.codex/skills` location;
- the repository `.codex` directory contains no ignored or untracked runtime
  files.

`.scripts/setup-codex-home --apply` only:

- creates the real `~/.codex` directory when missing;
- links tracked configuration files individually;
- links `~/.agents` to the repository `.agents` directory;
- backs up a conflicting link destination under `~/.dotfiles-backups/`.

It deliberately does not inspect, edit, move, or repair databases, sessions,
rollouts, plugins, caches, or worktrees. Those are Codex runtime state, not a
dotfiles concern.

## Unsafe Legacy Layouts

The helper refuses this layout:

```text
~/.codex -> <dotfiles>/.codex
```

A whole-directory migration may contain live runtime state and absolute paths.
The permanent dotfiles helper cannot safely infer how to rewrite internal Codex
data, so it stops instead of guessing. Preserve the existing directory and use
a separate, backed-up recovery procedure appropriate to the installed Codex
version.

The helper also stops if runtime files appear inside the repository `.codex`.
Review those files before moving anything; do not delete runtime state merely
to make Git clean.

## Skills

Current Codex discovers user-wide skills under `~/.agents/skills`. In this
setup, that path resolves to `<dotfiles>/.agents/skills`.

- Commit skills authored for this dotfiles setup.
- Record third-party skills in `skills-lock.json` and ignore generated copies.
- Do not author user skills under `<dotfiles>/.codex/skills` or
  `~/.codex/skills`.

The required `linear-status` manifest should therefore be readable at:

```text
~/.agents/skills/linear-status/SKILL.md
```

## `paradevbox`

The remote machine uses the same boundary:

```text
/Users/giulio/repos/dotfiles/.codex/  configuration source
/Users/giulio/.codex/                 runtime home
/Users/giulio/.agents/                link to the repository .agents
```

Verification and link repair can be run over SSH:

```bash
ssh paradevbox \
  'cd ~/repos/dotfiles && ./.scripts/setup-codex-home --check'

ssh paradevbox \
  'cd ~/repos/dotfiles && ./.scripts/setup-codex-home --apply'
```

Leave remote `CODEX_HOME` unset, or set it only to the real runtime directory
`/Users/giulio/.codex`.

## Official References

- [OpenAI Docs: config and state locations](https://learn.chatgpt.com/docs/config-file/config-advanced#config-and-state-locations)
- [OpenAI Docs: local skill discovery](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills)
- [OpenAI Docs: Git worktrees](https://learn.chatgpt.com/docs/environments/git-worktrees)
