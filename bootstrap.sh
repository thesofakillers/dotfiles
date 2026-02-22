#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
OS_NAME="$(uname -s)"
BREWFILE_PATH="$REPO_DIR/Brewfile"
APT_PACKAGES_MANIFEST="$REPO_DIR/manifests/apt-packages.txt"
BREW_PACKAGES_MANIFEST="$REPO_DIR/manifests/brew-packages.txt"

INTERACTIVE=1
DO_CONFIRM=1
INSTALL_PACKAGES=1
INSTALL_TPM=1
INSTALL_HOMEBREW=0
INSTALL_RUNTIMES=1
INSTALL_NVIM_PLUGINS=0

INSTALL_PACKAGES_SET=0
INSTALL_TPM_SET=0
INSTALL_HOMEBREW_SET=0
INSTALL_RUNTIMES_SET=0
INSTALL_NVIM_PLUGINS_SET=0

log() {
  printf '[bootstrap] %s\n' "$*"
}

manifest_entries() {
  local manifest="$1"

  if [[ ! -f "$manifest" ]]; then
    return 1
  fi

  sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$manifest"
}

usage() {
  cat <<'USAGE'
Usage: ./bootstrap.sh [options]

Bootstraps this dotfiles repo on a machine.

Options:
  --non-interactive, --yes, -y
      Skip interactive prompts and run with current/default options.
  --no-confirm
      Skip the final "Proceed?" confirmation prompt.

  --skip-packages | --install-packages
      Disable/enable baseline package installation.
  --skip-tpm | --install-tpm
      Disable/enable tmux TPM installation.
  --with-homebrew | --without-homebrew
      Enable/disable Homebrew installation when missing.
  --with-runtimes | --without-runtimes
      Enable/disable installing developer runtimes (uv, bun, node via n).
  --with-nvim-plugins | --without-nvim-plugins
      Enable/disable running Neovim plugin installation.

  -h, --help
      Show this help.
USAGE
}

run_with_sudo() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  elif command -v sudo > /dev/null 2>&1; then
    sudo "$@"
  else
    printf 'sudo is required when running as a non-root user.\n' >&2
    exit 1
  fi
}

bool_word() {
  if [[ "$1" -eq 1 ]]; then
    printf 'yes'
  else
    printf 'no'
  fi
}

prompt_yes_no() {
  local question="$1"
  local default="$2"
  local outvar="$3"
  local suffix input normalized value

  if [[ "$default" -eq 1 ]]; then
    suffix='[Y/n]'
  else
    suffix='[y/N]'
  fi

  while true; do
    read -r -p "$question $suffix " input || input=''

    if [[ -z "$input" ]]; then
      value="$default"
      break
    fi

    normalized="$(printf '%s' "$input" | tr '[:upper:]' '[:lower:]')"
    case "$normalized" in
      y|yes)
        value=1
        break
        ;;
      n|no)
        value=0
        break
        ;;
      *)
        printf 'Please answer yes or no.\n'
        ;;
    esac
  done

  printf -v "$outvar" '%s' "$value"
}

backup_path() {
  local target="$1"
  local relative="${target#"$HOME"/}"
  local destination

  if [[ "$relative" == "$target" ]]; then
    destination="$BACKUP_ROOT/$(basename "$target")"
  else
    destination="$BACKUP_ROOT/$relative"
  fi

  mkdir -p "$(dirname "$destination")"
  mv "$target" "$destination"
  log "Backed up $target -> $destination"
}

link_path() {
  local src="$1"
  local dest="$2"

  if [[ "$src" == "$dest" ]]; then
    log "Skipping self-link for $dest."
    return
  fi

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    log "Skipping missing source: $src"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    log "Already linked: $dest"
    return
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    backup_path "$dest"
  fi

  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

load_brew_shellenv() {
  if command -v brew > /dev/null 2>&1; then
    eval "$(brew shellenv)"
    return
  fi

  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
}

install_homebrew_if_requested() {
  if [[ "$INSTALL_HOMEBREW" -ne 1 ]]; then
    return
  fi

  if command -v brew > /dev/null 2>&1; then
    log "Homebrew already installed."
    return
  fi

  if [[ "$OS_NAME" != "Darwin" && "$OS_NAME" != "Linux" ]]; then
    log "Skipping Homebrew install (unsupported OS: $OS_NAME)."
    return
  fi

  if ! command -v curl > /dev/null 2>&1; then
    if command -v apt-get > /dev/null 2>&1; then
      log "curl not found; installing curl first via apt-get."
      run_with_sudo apt-get update
      run_with_sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates
    else
      log "Skipping Homebrew install (curl missing and apt-get unavailable)."
      return
    fi
  fi

  log "Installing Homebrew."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_brew_shellenv

  if command -v brew > /dev/null 2>&1; then
    log "Homebrew installation complete."
  else
    log "Homebrew installation finished, but brew is not in PATH yet. Open a new shell."
  fi
}

install_packages_apt() {
  local -a packages=()
  local pkg

  if [[ ! -f "$APT_PACKAGES_MANIFEST" ]]; then
    log "Skipping apt-get package install (missing manifest: $APT_PACKAGES_MANIFEST)."
    return
  fi

  while IFS= read -r pkg; do
    packages+=("$pkg")
  done < <(manifest_entries "$APT_PACKAGES_MANIFEST")

  if [[ "${#packages[@]}" -eq 0 ]]; then
    log "Skipping apt-get package install (no packages listed in $APT_PACKAGES_MANIFEST)."
    return
  fi

  log "Installing baseline packages with apt-get from $APT_PACKAGES_MANIFEST."
  run_with_sudo apt-get update
  run_with_sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"

  if command -v fdfind > /dev/null 2>&1 && ! command -v fd > /dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

install_packages_brew() {
  load_brew_shellenv
  local -a packages=()
  local pkg

  if ! command -v brew > /dev/null 2>&1; then
    log "Skipping brew package install (brew not available in this shell)."
    return
  fi

  log "Installing packages with Homebrew."
  brew update

  if [[ -f "$BREWFILE_PATH" ]]; then
    if brew bundle --file="$BREWFILE_PATH"; then
      log "Installed packages from $BREWFILE_PATH."
      return
    fi
    log "brew bundle failed; falling back to baseline package list."
  else
    log "Brewfile not found at $BREWFILE_PATH; using fallback package list."
  fi

  if [[ ! -f "$BREW_PACKAGES_MANIFEST" ]]; then
    log "Skipping fallback brew install (missing manifest: $BREW_PACKAGES_MANIFEST)."
    return
  fi

  while IFS= read -r pkg; do
    packages+=("$pkg")
  done < <(manifest_entries "$BREW_PACKAGES_MANIFEST")

  if [[ "${#packages[@]}" -eq 0 ]]; then
    log "Skipping fallback brew install (no packages listed in $BREW_PACKAGES_MANIFEST)."
    return
  fi

  brew install "${packages[@]}"
}

planned_package_manager() {
  if [[ "$INSTALL_PACKAGES" -ne 1 ]]; then
    printf 'skip'
    return
  fi

  if command -v apt-get > /dev/null 2>&1; then
    printf 'apt-get'
    return
  fi

  if command -v brew > /dev/null 2>&1; then
    printf 'brew'
    return
  fi

  if [[ "$INSTALL_HOMEBREW" -eq 1 ]]; then
    printf 'brew (after install)'
    return
  fi

  printf 'none found'
}

install_packages() {
  if command -v apt-get > /dev/null 2>&1; then
    install_packages_apt
    return
  fi

  load_brew_shellenv
  if command -v brew > /dev/null 2>&1; then
    install_packages_brew
    return
  fi

  log "Skipping package install (supported managers not found: apt-get, brew)."
}

install_uv_if_missing() {
  if command -v uv > /dev/null 2>&1; then
    log "uv already installed."
    return
  fi

  if ! command -v curl > /dev/null 2>&1; then
    log "Skipping uv install (curl not found)."
    return
  fi

  log "Installing uv."
  if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
    log "uv install failed; continuing."
    return
  fi

  export PATH="$HOME/.local/bin:$PATH"
  log "uv installation complete."
}

install_bun_if_missing() {
  if command -v bun > /dev/null 2>&1; then
    log "bun already installed."
    return
  fi

  if ! command -v curl > /dev/null 2>&1; then
    log "Skipping bun install (curl not found)."
    return
  fi

  log "Installing bun."
  if ! curl -fsSL https://bun.sh/install | bash; then
    log "bun install failed; continuing."
    return
  fi

  export PATH="$HOME/.bun/bin:$PATH"
  log "bun installation complete."
}

install_node_if_missing() {
  local n_path="$HOME/n/bin"

  if command -v node > /dev/null 2>&1 || [[ -x "$n_path/node" ]]; then
    log "Node already installed."
    export PATH="$n_path:$PATH"
  else
    if ! command -v curl > /dev/null 2>&1; then
      log "Skipping node install (curl not found)."
      return
    fi

    log "Installing node via n-install."
    if ! curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n-install | bash -s -- -y; then
      log "node install failed; continuing."
      return
    fi
    export PATH="$n_path:$PATH"
  fi

  if ! command -v npm > /dev/null 2>&1; then
    log "npm not found after node install; skipping global neovim npm package."
    return
  fi

  if ! npm list -g --depth=0 neovim > /dev/null 2>&1; then
    log "Installing global npm package: neovim."
    if ! npm install -g neovim; then
      log "npm global neovim install failed; continuing."
      return
    fi
  fi
}

install_runtimes_if_requested() {
  if [[ "$INSTALL_RUNTIMES" -ne 1 ]]; then
    return
  fi

  install_uv_if_missing
  install_bun_if_missing
  install_node_if_missing
}

setup_links() {
  link_path "$REPO_DIR/.bash_profile" "$HOME/.bash_profile"
  link_path "$REPO_DIR/.bash_prompt" "$HOME/.bash_prompt"
  link_path "$REPO_DIR/.bash_scripts" "$HOME/.bash_scripts"
  link_path "$REPO_DIR/.bashrc" "$HOME/.bashrc"
  link_path "$REPO_DIR/.installs" "$HOME/.installs"
  link_path "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
  link_path "$REPO_DIR/.scripts" "$HOME/.scripts"

  link_path "$REPO_DIR/.config/git/config" "$HOME/.config/git/config"
  link_path "$REPO_DIR/.config/git/config.aliases" "$HOME/.config/git/config.aliases"
  link_path "$REPO_DIR/.config/git/ignore" "$HOME/.config/git/ignore"

  link_path "$REPO_DIR/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua"
  link_path "$REPO_DIR/.config/nvim/coc-settings.json" "$HOME/.config/nvim/coc-settings.json"

  link_path "$REPO_DIR/.vim/vimrc" "$HOME/.vim/vimrc"
  link_path "$REPO_DIR/.vim/autoload/plug.vim" "$HOME/.vim/autoload/plug.vim"
}

setup_local_files() {
  if [[ ! -f "$HOME/.config/git/config.secret" ]]; then
    cat > "$HOME/.config/git/config.secret" <<'EOF_SECRET'
# Local-only git settings go here.
# Example:
# [user]
#   email = your.email@example.com
EOF_SECRET
    log "Created $HOME/.config/git/config.secret template."
  fi
}

setup_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  if [[ -d "$tpm_dir/.git" ]]; then
    log "TPM already installed."
    return
  fi

  mkdir -p "$(dirname "$tpm_dir")"
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  log "Installed TPM at $tpm_dir."
}

install_nvim_plugins_if_requested() {
  if [[ "$INSTALL_NVIM_PLUGINS" -ne 1 ]]; then
    return
  fi

  if ! command -v nvim > /dev/null 2>&1; then
    log "Skipping Neovim plugin install (nvim not found)."
    return
  fi

  log "Installing Neovim plugins."
  if nvim --headless '+PlugInstall --sync' '+qall'; then
    log "Neovim plugins installed."
  else
    log "Neovim plugin install failed. Run manually: nvim +PlugInstall +qall"
  fi
}

configure_interactive() {
  local default_homebrew=0
  local default_packages=1

  log "Interactive setup: answer a few questions (Enter accepts defaults)."

  if [[ "$INSTALL_HOMEBREW_SET" -eq 0 ]]; then
    if command -v brew > /dev/null 2>&1; then
      INSTALL_HOMEBREW=0
      log "Homebrew already installed; skipping Homebrew install question."
    else
      if [[ "$OS_NAME" == "Darwin" ]]; then
        default_homebrew=1
      fi
      prompt_yes_no "Install Homebrew if missing?" "$default_homebrew" INSTALL_HOMEBREW
    fi
  fi

  if [[ "$INSTALL_PACKAGES_SET" -eq 0 ]]; then
    if ! command -v apt-get > /dev/null 2>&1 && ! command -v brew > /dev/null 2>&1 && [[ "$INSTALL_HOMEBREW" -ne 1 ]]; then
      default_packages=0
    fi
    prompt_yes_no "Install baseline CLI packages?" "$default_packages" INSTALL_PACKAGES
  fi

  if [[ "$INSTALL_TPM_SET" -eq 0 ]]; then
    prompt_yes_no "Install tmux TPM plugin manager?" 1 INSTALL_TPM
  fi

  if [[ "$INSTALL_RUNTIMES_SET" -eq 0 ]]; then
    prompt_yes_no "Install developer runtimes (uv, bun, node via n)?" 1 INSTALL_RUNTIMES
  fi

  if [[ "$INSTALL_NVIM_PLUGINS_SET" -eq 0 ]]; then
    prompt_yes_no "Install Neovim plugins now?" 0 INSTALL_NVIM_PLUGINS
  fi
}

print_plan() {
  local pkg_manager
  pkg_manager="$(planned_package_manager)"

  printf '\nBootstrap plan:\n'
  printf '  - Link dotfiles: yes\n'
  printf '  - Create local templates: yes\n'
  printf '  - Install Homebrew if missing: %s\n' "$(bool_word "$INSTALL_HOMEBREW")"
  printf '  - Install baseline packages: %s' "$(bool_word "$INSTALL_PACKAGES")"
  if [[ "$INSTALL_PACKAGES" -eq 1 ]]; then
    printf ' (%s)' "$pkg_manager"
  fi
  printf '\n'
  printf '  - Install tmux TPM: %s\n' "$(bool_word "$INSTALL_TPM")"
  printf '  - Install runtimes (uv, bun, node): %s\n' "$(bool_word "$INSTALL_RUNTIMES")"
  printf '  - Install Neovim plugins now: %s\n\n' "$(bool_word "$INSTALL_NVIM_PLUGINS")"
}

confirm_plan_or_exit() {
  local proceed=1

  if [[ "$INTERACTIVE" -eq 1 && "$DO_CONFIRM" -eq 1 ]]; then
    prompt_yes_no "Proceed with this plan?" 1 proceed
    if [[ "$proceed" -ne 1 ]]; then
      log "Cancelled by user."
      exit 0
    fi
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --non-interactive|--yes|-y)
        INTERACTIVE=0
        DO_CONFIRM=0
        ;;
      --no-confirm)
        DO_CONFIRM=0
        ;;
      --skip-packages)
        INSTALL_PACKAGES=0
        INSTALL_PACKAGES_SET=1
        ;;
      --install-packages)
        INSTALL_PACKAGES=1
        INSTALL_PACKAGES_SET=1
        ;;
      --skip-tpm)
        INSTALL_TPM=0
        INSTALL_TPM_SET=1
        ;;
      --install-tpm)
        INSTALL_TPM=1
        INSTALL_TPM_SET=1
        ;;
      --with-homebrew)
        INSTALL_HOMEBREW=1
        INSTALL_HOMEBREW_SET=1
        ;;
      --without-homebrew)
        INSTALL_HOMEBREW=0
        INSTALL_HOMEBREW_SET=1
        ;;
      --with-runtimes)
        INSTALL_RUNTIMES=1
        INSTALL_RUNTIMES_SET=1
        ;;
      --without-runtimes)
        INSTALL_RUNTIMES=0
        INSTALL_RUNTIMES_SET=1
        ;;
      --with-nvim-plugins)
        INSTALL_NVIM_PLUGINS=1
        INSTALL_NVIM_PLUGINS_SET=1
        ;;
      --without-nvim-plugins)
        INSTALL_NVIM_PLUGINS=0
        INSTALL_NVIM_PLUGINS_SET=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n\n' "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  if [[ ! -t 0 ]] && [[ "$INTERACTIVE" -eq 1 ]]; then
    INTERACTIVE=0
    DO_CONFIRM=0
    log "Standard input is not a TTY; switching to non-interactive mode."
  fi

  if [[ "${EUID}" -eq 0 ]]; then
    log "Running as root; dotfiles will be linked under /root."
    log "Use a normal user account if this is not intentional."
  fi

  if [[ "$INTERACTIVE" -eq 1 ]]; then
    configure_interactive
  fi

  print_plan
  confirm_plan_or_exit

  install_homebrew_if_requested

  if [[ "$INSTALL_PACKAGES" -eq 1 ]]; then
    install_packages
  fi

  install_runtimes_if_requested

  setup_links
  setup_local_files

  if [[ "$INSTALL_TPM" -eq 1 ]]; then
    setup_tpm
  fi

  install_nvim_plugins_if_requested

  log "Bootstrap complete."
  log "Start a fresh shell: exec bash -l"
}

main "$@"
