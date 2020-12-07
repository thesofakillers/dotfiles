# macOS comes with legacy ncurses that doesn't understand tmux-256color
# https://github.com/tmux/tmux/issues/2262
infocmp -x tmux-256color >xyz
/use/bin/tic -x xyz
rm xyz
