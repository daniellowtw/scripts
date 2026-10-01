#!/usr/bin/env bash

set -e

# Get script directory and load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
load_versions

install_conda() {
    if command_exists conda; then
        warn "Conda is already installed ($(conda --version))"
        return 0
    fi

    info "Installing Miniforge ${MINIFORGE_VERSION}..."
    warn "This installer is interactive and will prompt for input"

    local os=$(uname)
    local arch
    case "$(get_arch)" in
        amd64) arch="x86_64" ;;
        arm64) arch="aarch64" ;;
        *)
            warn "Miniforge does not support 32-bit ARM, skipping (use a 64-bit OS)"
            return 0
            ;;
    esac
    local installer="Miniforge3-${MINIFORGE_VERSION}-${os}-${arch}.sh"
    local url="https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${installer}"

    # Download
    curl -fL -O "${url}"

    # Run installer
    bash "${installer}"

    # Cleanup
    rm "${installer}"

    success "Miniforge ${MINIFORGE_VERSION} installed"
    info "Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_conda
fi
