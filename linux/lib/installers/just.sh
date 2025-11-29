#!/usr/bin/env bash

set -e

# Get script directory and load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
load_versions

install_just() {
    if command_exists just; then
        warn "just is already installed ($(just --version))"
        if ! confirm "Reinstall just ${JUST_VERSION}?"; then
            return 0
        fi
    fi

    info "Installing just ${JUST_VERSION}..."

    local arch="x86_64"
    local binary="just-${JUST_VERSION}-${arch}-unknown-linux-musl.tar.gz"
    local url="https://github.com/casey/just/releases/download/${JUST_VERSION}/${binary}"

    # Download and extract
    info "Downloading from ${url}..."
    wget "${url}" -O "/tmp/${binary}"
    tar -xzf "/tmp/${binary}" -C /tmp just

    # Move to /usr/local/bin
    ensure_sudo
    sudo mv /tmp/just /usr/local/bin/just
    sudo chmod +x /usr/local/bin/just

    # Cleanup
    rm -f "/tmp/${binary}"

    success "just ${JUST_VERSION} installed ($(just --version))"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_just
fi
