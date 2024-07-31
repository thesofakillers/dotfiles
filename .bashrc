# If not running interactively, don't do anything and return early
[[ $- == *i* ]] || return

[[ -f "$HOME/.bash_profile" ]] && source "$HOME/.bash_profile"
