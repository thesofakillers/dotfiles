# {{{ sourcing
# Prompt
[[ -f "$HOME/.bash_prompt" ]] && source "$HOME/.bash_prompt"
# Secrets 
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"
# }}}

# {{{ general settings
# Larger bash history (default is 500)
export HISTFILESIZE=10000
export HISTSIZE=10000

PATH="/usr/local/bin:/usr/local/sbin:$PATH"

export BASH_SILENCE_DEPRECATION_WARNING=1
# }}}

# {{{ rbvenv
eval "$(rbenv init -)"
# }}}

# {{{ conda/miniconda
export PATH=~/miniconda3/bin:$PATH


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('~/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
# }}}

# {{{ fzf
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
# }}}

# {{{ python poetry
export PATH="$HOME/.poetry/bin:$PATH"
# }}}

# {{{ node version manager
export NVM_DIR="$HOME/.nvm"
# This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
 # This loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# }}}
