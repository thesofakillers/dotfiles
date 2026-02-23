#!/usr/bin/env bash

load_brew_shellenv() {
  local brew_bin=""

  if command -v brew > /dev/null 2>&1; then
    eval "$(brew shellenv)"
    return 0
  fi

  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    brew_bin="/opt/homebrew/bin/brew"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    brew_bin="/usr/local/bin/brew"
  elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
  elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
    brew_bin="$HOME/.linuxbrew/bin/brew"
  fi

  if [[ -n "$brew_bin" ]]; then
    eval "$("$brew_bin" shellenv)"
    return 0
  fi

  return 1
}
