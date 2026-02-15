#!/usr/bin/env bash

set -e

# Get script directory and load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

install_apt_packages() {
  info "Installing APT packages..."

  local packages=(
    ripgrep
    curl
    jq
    gh
    build-essential
    git
    fzf
    vim
    htop
    zsh
    gpg
  )

  ensure_sudo
  sudo apt update
  sudo apt install -y "${packages[@]}"

  success "APT packages installed"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_apt_packages
fi
