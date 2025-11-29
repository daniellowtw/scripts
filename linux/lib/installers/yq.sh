#!/usr/bin/env bash

set -e

# Get script directory and load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
load_versions

install_yq() {
    if command_exists yq; then
        warn "yq is already installed ($(yq --version))"
        if ! confirm "Reinstall yq ${YQ_VERSION}?"; then
            return 0
        fi
    fi

    info "Installing yq ${YQ_VERSION}..."

    local binary="yq_linux_amd64"
    local url="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${binary}.tar.gz"

    # Download and extract
    wget "${url}" -O - | tar xz

    # Move to /usr/bin
    ensure_sudo
    sudo mv "${binary}" /usr/bin/yq
    sudo chmod +x /usr/bin/yq

    success "yq ${YQ_VERSION} installed"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_yq
fi
