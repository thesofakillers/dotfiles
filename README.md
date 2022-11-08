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
