# {{{ sourcing
# Prompt
[[ -f "$HOME/.bash_prompt" ]] && source "$HOME/.bash_prompt"
# Secrets
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"
# Installs (conda, rbenv, fzf, etc)
[[ -f "$HOME/.installs" ]] && source "$HOME/.installs"
# My own scripts
[[ -f "$HOME/.bash_scripts" ]] && source "$HOME/.bash_scripts"
# If we're on an ssh server, ill move all the custom stuff here
[[ -f "$HOME/.serverthings" ]] && source "$HOME/.serverthings"
# finally, clean up, removing duplicates from PATH
export PATH=$(echo $PATH | tr ':' '\n' | sort -u | tr '\n' ':')
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

# {{{ custom functions
# show sizes of directories https://stackoverflow.com/a/38032798/9889508
function duls {
    paste <( du -hs -- "$@" | cut -f1 ) <( ls -ld -- "$@" )
}

# touch all files in a directory recursively: https://askubuntu.com/a/580413/1003945
function toucheverything() {
      find "$1" -type f -exec touch {} +
}

# }}}

# {{{ aliases
# ls --group-directories-first on mac
# https://unix.stackexchange.com/a/581394/376432
alias ll='ls -lh | sort -r | awk '\''NF==9 { if ($1~/^d/) { printf $1 "/" $2 "/" $3 "/" $4 "/" $5 "/" $6 " " $7 "/" $8 " " "\033[1;34m" $9 "\033[0m" "\n" } else { printf $1 "/" $2 "/" $3 "/" $4 "/" $5 "/" $6 " " $7 "/" $8 " " "\033[1;32m" $9 "\033[0m" "\n" } }'\'' | column -t -s"/"'
# }}}
