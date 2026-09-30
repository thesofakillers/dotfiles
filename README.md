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
- links `~/.claude/skills` to `~/.agents/skills` so Claude Code sees the same
  skills as Codex and OpenCode (see [Agent Skills](#agent-skills))
- links `~/.claude/CLAUDE.md`, which imports `~/.codex/AGENTS.md` so Claude
  Code follows the same user-level instructions as Codex
- backs up any replaced files to `~/.dotfiles-backups/<timestamp>/...`
- creates a local-only git template at `~/.config/git/config.secret`
- sets the account login shell to Bash on every OS (these dotfiles only
  configure Bash; changing it may request authentication), pins tmux's
  `default-shell` to Bash, and on macOS configures new Apple Terminal windows
  to start Bash
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

### One skills directory for every agent

`.agents/skills/` in this repo is the single source of truth for user-level
skills. Bootstrap links `~/.agents` to this repo and then points the other
agents' global skill directories at it:

| Agent       | Reads user skills from | How it sees `.agents/skills/`                  |
| ----------- | ---------------------- | ---------------------------------------------- |
| Codex       | `~/.agents/skills/`    | natively                                       |
| OpenCode    | `~/.agents/skills/`    | natively (also reads `~/.claude/skills/`)      |
| Claude Code | `~/.claude/skills/`    | `~/.claude/skills` is a symlink to it          |

So a skill added under `.agents/skills/<name>/SKILL.md` is available to all of
them immediately; there is no per-skill linking, sync, or install step.

Rules that keep this working:

- Author skills in `.agents/skills/<name>/`. Never put skills directly in
  `~/.claude/skills/`, `~/.config/opencode/skills/`, or `~/.codex/skills/`.
  `~/.claude/skills` is the same directory, and the other two are not read for
  user skills (`~/.codex/skills/` is Codex-managed runtime state such as
  `.system`; `.config/opencode/skills/` is gitignored because OpenCode reads
  `~/.agents/skills` itself).
- Do not replace the `~/.claude/skills` symlink with a real directory. If an
  existing machine has one, re-run `./bootstrap.sh`: it backs the directory up
  to `~/.dotfiles-backups/<timestamp>/` and creates the link.
- The Skills CLI is safe with this layout. When it installs a skill for Claude
  Code it detects that `~/.claude/skills/<name>` already resolves to
  `~/.agents/skills/<name>` and skips creating a link.
- Codex normally detects changes automatically; restart Codex or Claude Code
  if an already-open skill picker is stale.

### Third-party skills

Vercel's Skills CLI uses `.agents/skills/` as its standard directory, and this
repo uses the root-level `skills-lock.json` as the reproducible manifest and
lock file for third-party skills. Installer-managed copies are gitignored; the
lock file records their source and content hash.

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
- skill links under `.config/opencode/skills/` (gitignored; OpenCode reads
  `~/.agents/skills` directly)
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
and Codex-managed worktrees belong directly under `~/.codex`. They are
runtime-owned and must not be copied into the repository.

The complete ownership, setup, and `paradevbox` notes are in
[docs/codex.md](docs/codex.md). Read them before changing `.codex`,
`CODEX_HOME`, bootstrap linking, or skill locations.

The bootstrapper runs [`.scripts/setup-codex-home`](.scripts/setup-codex-home).
To repair the managed links, run:

```bash
./.scripts/setup-codex-home --apply
./.scripts/setup-codex-home --check
```

`--check` is read-only. `--apply` only creates links and backs up conflicting
link destinations under `~/.dotfiles-backups/`. It does not inspect or migrate
Codex runtime state and refuses a whole-directory `~/.codex` symlink.

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
