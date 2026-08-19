# Dotfiles

## Quick Start

On a fresh machine, logged in as your regular user:

```bash
git clone <your-dotfiles-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
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
  configuration and custom-skill files into it
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

- custom skills authored for this dotfiles setup
- small, stable project skills that should travel with the repo
- `skills-lock.json`, when third-party skills should be reproducible

Do not track:

- host/runtime-managed skills such as `.codex/skills/.system/`
- generated local runtime state such as `.codex/app-server-control/`
- installer-managed vendor bundles such as `.agents/skills/flywheel*/`

## Codex State Boundary

`~/.codex` must be a real directory, not a symlink to this repository. The
[official Codex state documentation](https://learn.chatgpt.com/docs/config-file/config-advanced#config-and-state-locations)
defines this as the per-user state root; this setup stores SQLite databases,
session rollouts, archives, logs, packages, plugins, and worktrees there.
Keeping the whole directory behind a symlink can give the same rollout two path
spellings and break lifecycle operations such as archive and unarchive.

The bootstrapper runs [`.scripts/setup-codex-home`](.scripts/setup-codex-home),
which links only Git-tracked files from this repository's `.codex/` directory
into the real runtime directory. On an older checkout where `~/.codex` still
points at the repository, quit the Codex desktop app and CLI sessions, then run:

```bash
./.scripts/setup-codex-home --apply
./.scripts/setup-codex-home --check
codex doctor --summary
```

The migration moves runtime state rather than deleting it. Conflicting managed
files are backed up under `~/.dotfiles-backups/`, and existing Codex-managed Git
worktrees are repaired after their runtime directory moves.

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
