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
- symlinks the main dotfiles and managed directories (`.codex`, `.vim`, and
  top-level entries under `.config`)
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

Vercel's Skills CLI treats `.agents/skills/` as a standard project-scoped
skills directory, and uses `.agents/.skill-lock.json` to track installed
GitHub-backed skills. In this dotfiles repo, version-control skill source only
when it is intentionally maintained here or represented by the lock file.

Do track:

- custom skills authored for this dotfiles setup
- small, stable project skills that should travel with the repo
- `.agents/.skill-lock.json`, when third-party skills should be reproducible

Do not track:

- host/runtime-managed skills such as `.codex/skills/.system/`
- generated local runtime state such as `.codex/app-server-control/`
- installer-managed vendor bundles such as `.agents/skills/flywheel*/`

Install or refresh third-party skills through their installer instead of
committing copied vendor output. For example, restore Skills CLI-managed
entries from `.agents/.skill-lock.json`, and reinstall Flywheel skills with the
Flywheel installer only when that host integration is needed locally.

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
