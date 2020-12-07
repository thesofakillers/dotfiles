# {{{ sourcing
# Prompt
[[ -f "$HOME/.bash_prompt" ]] && source "$HOME/.bash_prompt"
# Secrets 
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"
# Installs (conda, rbenv, fzf, etc) 
[[ -f "$HOME/.installs" ]] && source "$HOME/.installs"

# }}}

# {{{ general settings
# Larger bash history (default is 500)
export HISTFILESIZE=10000
export HISTSIZE=10000

PATH="/usr/local/bin:/usr/local/sbin:$PATH"

export BASH_SILENCE_DEPRECATION_WARNING=1
# }}}
