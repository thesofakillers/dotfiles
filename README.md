# Dotfiles

Clone this repository. Then use symbolic linking to set the relevant files where
they need to be relative to your `~`.

For example, if you wish for `dotfiles/folder/` to appear in `~/folder` then run

```bash
ln -s path/to/dotfiles/folder ~/folder
```

## Vim

I don't use neovim (yet), instead opting for vim8. I use
[vim-plugged](https://github.com/junegunn/vim-plug) for packages.

## Additional Setup

Remember to run [brew.sh](brew.sh) and
[additional-installs.sh](additional-installs.sh) to complete the setup with
necessary programs.
