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
function workdisplay() {
  echo "Running displayplacer, this takes roughly 10 seconds"
  displayplacer \
    "id:9CA1B3C1-5305-A77E-BA48-E4DCEE26CA1A res:1920x1080 hz:60 color_depth:8 scaling:off origin:(0,0) degree:0" \
    "id:0C813C86-6289-1EFA-29DB-4AC73278DA9E res:1440x900 color_depth:8 scaling:on origin:(210,1080) degree:0"
}
function homedisplay() {
  echo "Running displayplacer, this takes roughly 10 seconds"
  displayplacer \
    "id:1569F1F1-64A6-361E-D96F-D11BE9E8C97B res:1920x1080 hz:60 color_depth:8 scaling:off origin:(0,0) degree:0" \
    "id:0C813C86-6289-1EFA-29DB-4AC73278DA9E res:1440x900 color_depth:8 scaling:on origin:(-1440,0) degree:0"
}
# }}}

# {{{ aliases
# ls --group-directories-first on mac
# https://unix.stackexchange.com/a/581394/376432
alias ll='ls -lh | sort -r | awk '\''NF==9 { if ($1~/^d/) { printf $1 "/" $2 "/" $3 "/" $4 "/" $5 "/" $6 " " $7 "/" $8 " " "\033[1;34m" $9 "\033[0m" "\n" } else { printf $1 "/" $2 "/" $3 "/" $4 "/" $5 "/" $6 " " $7 "/" $8 " " "\033[1;32m" $9 "\033[0m" "\n" } }'\'' | column -t -s"/"'
# }}}
