vim.opt.runtimepath:prepend("~/.vim")
vim.opt.runtimepath:append("~/.vim/after")
vim.opt.packpath = vim.opt.runtimepath

-- Load common vim settings
vim.cmd('source ~/.vim/vimrc')
