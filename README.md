# Dotfiles

Clone this repository. Then use symbolic linking to set the relevant files where
they need to be relative to your `~`.

For example, if you wish for `dotfiles/folder/` to appear in `~/folder` then run

```bash
ln -s path/to/dotfiles/folder ~/folder
```

## Vim/Neovim

I use [neovim](https://neovim.io/) as I believe that it is less likely to
stagnate and in the long run will outlive vim. That being said I originally used
vim so the config is shared between the two for now. I use
[vim-plugged](https://github.com/junegunn/vim-plug) for packages.

### Neovim / Coc specifics

- Coc uses `~/n/bin/node`; keep `n` on PATH.
- Coc extensions live in `~/.config/coc/extensions`; run `:CocUpdate` after
  changing Node.
- Neovim Python host lives in `~/.local/share/nvim-py3` with `pynvim` installed
  (recreate with `python3 -m venv ~/.local/share/nvim-py3 && ~/.local/share/nvim-py3/bin/pip install -U pynvim`).
- Built-in node/perl/ruby providers are disabled; only Coc’s node host is used.
- Coc-pyright is installed. Ruff lint/format uses `~/.scripts/ruff-fallback`:
  looks for `./.venv/ruff`, then PATH ruff, else no-op (prevents EPIPE when
  ruff is missing). Install ruff in each project venv for full lint/format.

## Additional Setup

You may wish to run or at least to refer to the contents of

- [brew.sh](brew.sh)
- [node.sh](node.sh)
- [additional-installs.sh](additional-installs.sh)
- [mac_finish.sh](mac_finish.sh) to complete the setup with necessary programs
  and configuration.

### tmux without root

For installing tmux without needing root access, please refer to
`tmux_local_install.sh`

### Servers and Custom environments

For custom environments for which you do not wish to commit things, add any
configuration to a file named `.serverthings` placed in the `$HOME` directory.
