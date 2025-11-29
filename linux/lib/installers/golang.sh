#!/usr/bin/env bash

set -e

# Get script directory and load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
load_versions

install_golang() {
    if command_exists go; then
        warn "Go is already installed ($(go version))"
        if ! confirm "Reinstall Go ${GO_VERSION}?"; then
            return 0
        fi
    fi

    info "Installing Go ${GO_VERSION}..."

    local archive="go${GO_VERSION}.linux-amd64.tar.gz"
    local url="https://go.dev/dl/${archive}"

    # Download
    curl -L -O "${url}"

    # Install to /usr/local
    ensure_sudo
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "${archive}"

    # Cleanup
    rm "${archive}"

    success "Go ${GO_VERSION} installed"
    info "Add to PATH: export PATH=\$PATH:/usr/local/go/bin"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_golang
fi
