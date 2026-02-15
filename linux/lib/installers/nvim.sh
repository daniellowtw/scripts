#!/usr/bin/env bash

set -e

# Get script directory and load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
load_versions

install_nvim() {
  if command_exists nvim; then
    warn "nvim is already installed ($(nvim --version | head -n1))"
    if ! confirm "Reinstall nvim ${NVIM_VERSION}?"; then
      return 0
    fi
  fi

  info "Installing nvim ${NVIM_VERSION}..."

  local archive="nvim-linu-x86_64.tar.gz"
  local url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${archive}"

  # Download
  curl -LO "${url}"

  # Install to /opt
  ensure_sudo
  sudo rm -rf /opt/nvim-linux64
  sudo tar -C /opt -xzf "${archive}"

  # Create symlink
  sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim

  # Cleanup
  rm "${archive}"

  success "nvim ${NVIM_VERSION} installed"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_nvim
fi
