#!/usr/bin/env bash

set -ex

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

  local arch
  case "$(get_arch)" in
  amd64) arch="x86_64" ;;
  arm64) arch="arm64" ;;
  *)
    warn "No official nvim build for 32-bit ARM, installing distro package instead"
    ensure_sudo
    sudo apt install -y neovim
    success "nvim installed from apt ($(nvim --version | head -n1))"
    return 0
    ;;
  esac

  local dir="nvim-linux-${arch}"
  local archive="${dir}.tar.gz"
  local url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${archive}"

  # Download
  curl -fLO "${url}"

  # Install to /opt
  ensure_sudo
  sudo rm -rf "/opt/${dir}/"
  sudo tar -C /opt -xzf "${archive}"

  # Create symlink
  sudo ln -sf "/opt/${dir}/bin/nvim" /usr/local/bin/nvim

  # Cleanup
  rm "${archive}"

  success "nvim ${NVIM_VERSION} installed"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_nvim
fi
