# {{{ sourcing
# Prompt
[[ -f "$HOME/.bash_prompt" ]] && source "$HOME/.bash_prompt"
# Secrets
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"
# Installs (conda, rbenv, fzf, etc)
[[ -f "$HOME/.installs" ]] && source "$HOME/.installs"
# My own scripts
[[ -f "$HOME/.bash_scripts" ]] && source "$HOME/.bash_scripts"
# }}}

# {{{ general settings
# Larger bash history (default is 500)
export HISTFILESIZE=10000
export HISTSIZE=10000
# UTF locale settings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

PATH="/usr/local/bin:/usr/local/sbin:$PATH"

set -o vi

export BASH_SILENCE_DEPRECATION_WARNING=1
# }}}

export XALT_EXECUTABLE_TRACKING=no

alias sqp='squeue -p gpu_shared_course'
alias squ='squeue -u $USER'
