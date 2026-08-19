# Dotfiles

## Quick Start

On a fresh machine, logged in as your regular user:

```bash
git clone <your-dotfiles-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
npx --yes skills experimental_install
./.scripts/setup-codex-home --check
exec bash -l
```

What `bootstrap.sh` does:

- asks a short interactive questionnaire first, then executes the selected
  setup plan
- installs baseline packages via manifests:
  - `apt`: `manifests/apt-packages.txt`
  - Homebrew: `Brewfile` (with fallback `manifests/brew-packages.txt`)
- optionally installs developer runtimes (`uv`, `bun`, and `node` via `n`)
- symlinks the main dotfiles and managed directories (`.vim`, `.agents`, and
  top-level entries under `.config`)
- keeps `~/.codex` as a real runtime directory and links only Git-tracked Codex
  configuration files into it; user skills are exposed separately through
  `~/.agents/skills`
- backs up any replaced files to `~/.dotfiles-backups/<timestamp>/...`
- creates a local-only git template at `~/.config/git/config.secret`
- sets up Neovim Python host in `~/.local/share/nvim-py3` with `pynvim`
  - on Debian/Ubuntu, bootstrap auto-installs missing `python3-venv` support
    when needed
- installs `tmux` TPM plugin manager
- skips package installation if no supported package manager is found

Useful flags:

```bash
./bootstrap.sh --non-interactive
./bootstrap.sh --skip-packages --without-runtimes
./bootstrap.sh --without-homebrew
./bootstrap.sh --with-nvim-plugins
```

After first login:

- start `tmux`, then press `prefix + I` to install tmux plugins
- run `nvim +PlugInstall +qall` and/or `vim +PlugInstall +qall` once to
  install plugins

## Agent Skills

Vercel's Skills CLI treats `.agents/skills/` as the standard skills directory.
This repo uses the root-level `skills-lock.json` as the reproducible dependency
manifest and lock file for third-party skills. Because bootstrap links
`~/.agents` to this repo, restored skills are available globally to compatible
agents, including Codex.

Standalone personal skills authored in this repository must also live under
`.agents/skills/`. Do not put them under `.codex/skills/`: current Codex loads
user-global skills from `~/.agents/skills`, so the legacy location can make a
skill appear in one task but disappear from tasks in other repositories or on
remote hosts. The same rule applies to the runtime path `~/.codex/skills/`:
only Codex-managed content such as `.system` belongs there. Codex normally
detects changes automatically; restart Codex if a skill picker that was
already open remains stale.

Add a dependency from the dotfiles root without `--global` so the project lock
file is updated:

```bash
npx skills add owner/repo --agent codex -y
```

Restore locked skills on a fresh machine, or update them later:

```bash
npx skills experimental_install
npx skills update --project -y
```

The similarly named `.agents/.skill-lock.json` is state for global (`-g`)
installs. It supports listing and updating already-installed global skills, but
the Skills CLI cannot use it to restore a fresh machine. Prefer project installs
and the root `skills-lock.json` for dotfiles-managed dependencies.

Do track:

- custom skills authored for this dotfiles setup under `.agents/skills/`
- small, stable project skills that should travel with the repo
- `skills-lock.json`, when third-party skills should be reproducible

Do not track:

- host/runtime-managed skills such as `.codex/skills/.system/`
- standalone authored skills under the legacy `.codex/skills/` location
- standalone user skills under the legacy `~/.codex/skills/` location
- generated local runtime state such as `.codex/app-server-control/`
- installer-managed vendor copies under `.agents/skills/`; track their source
  and content hash in `skills-lock.json` instead

## Codex Setup: Read This Before Changing `.codex`

The required layout is:

```text
<dotfiles>/.codex/  = Git-tracked configuration source
~/.codex/           = real, mutable Codex runtime directory
```

Tracked files such as `config.toml` and `AGENTS.md` are symlinked individually
from `~/.codex` back into this repository. The `~/.codex` directory itself must
never be a symlink, and `CODEX_HOME` must never point at this repository.

Sessions, archives, authentication, SQLite databases, plugins, logs, caches,
and Codex-managed worktrees belong directly under `~/.codex`. Mixing those
files into the repository can make remote tasks fail with `no rollout found`
or invalid worktree paths.

The complete setup, migration, `paradevbox`, verification, recovery, and backup
runbook is [docs/codex.md](docs/codex.md). Read it before changing
`.codex`, `CODEX_HOME`, bootstrap linking, or Codex worktree paths.

The bootstrapper runs [`.scripts/setup-codex-home`](.scripts/setup-codex-home).
For a repair, fully quit Codex desktop/CLI/remote sessions first, then run:

```bash
./.scripts/setup-codex-home --apply
./.scripts/setup-codex-home --check
```

`--check` is read-only. `--apply` preserves recoverability: conflicting files
are quarantined under `~/.dotfiles-backups/`, database and rollout repairs are
backed up under `~/.codex/repair-backups/`, and worktree metadata is repaired
after moves. Do not use `--force` during normal setup.

Install or refresh third-party skills through their installer instead of
committing copied vendor output. Restore Skills CLI-managed entries from
`skills-lock.json`, and reinstall Flywheel skills with the Flywheel installer
only when that host integration is needed locally.

## Manual Linking

If you prefer manual setup, clone this repository and create symlinks from files
inside the repo into your `$HOME`.

Example:

```bash
ln -s /path/to/dotfiles/.bashrc ~/.bashrc
```

## Vim/Neovim

### Neovim / Coc specifics

- Coc uses `~/n/bin/node`; keep `n` on PATH.
- Coc extensions live in `~/.config/coc/extensions`; run `:CocUpdate` after
  changing Node.
- Neovim Python host lives in `~/.local/share/nvim-py3` with `pynvim` installed
  (recreate with `python3 -m venv ~/.local/share/nvim-py3 &&
~/.local/share/nvim-py3/bin/pip install -U pynvim`).
- Built-in node/perl/ruby providers are disabled; only Coc’s node host is used.
- Coc-pyright is installed. Ruff lint/format uses `~/.scripts/ruff-fallback`:
  looks for `./.venv/ruff`, then PATH ruff, else no-op (prevents EPIPE when
  ruff is missing). Install ruff in each project venv for full lint/format.

## Additional Local Setup (Mac)

Most setup is covered by `bootstrap.sh`. For macOS terminal terminfo compatibility,
you may still need:

- [mac_finish.sh](mac_finish.sh)

### tmux without root

For installing tmux without needing root access, please refer to
`tmux_local_install.sh`

### Local-only git config

Use `~/.config/git/config.secret` for machine-specific git settings you do not
want to commit.
