# PATH entries needed even by non-interactive shells (e.g. ssh exec commands,
# which source this file on Debian/Ubuntu but return at the guard below).
# Keep this above the interactivity guard so git hooks/filters (git-lfs) work.
for _dir in "$HOME/.local/bin" /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin; do
  [[ -d "$_dir" && ":$PATH:" != *":$_dir:"* ]] && PATH="$_dir:$PATH"
done
unset _dir
export PATH

# If not running interactively, don't do anything and return early
[[ $- == *i* ]] || return

[[ -f "$HOME/.bash_profile" ]] && source "$HOME/.bash_profile"

# >>> flywheel PATH >>>
if ! printf "%s" ":$PATH:" | grep -F -q ':/home/giulio/.local/bin:'; then
  export PATH='/home/giulio/.local/bin':$PATH
fi
# <<< flywheel PATH <<<

# >>> Codex installer >>>
export PATH="/home/giulio/.local/bin:$PATH"
# <<< Codex installer <<<
