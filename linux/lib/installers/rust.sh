#!/usr/bin/env bash

set -e

# Get script directory and load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
load_versions

install_rust() {
    if command_exists rustup; then
        warn "Rust is already installed ($(rustc --version))"
        info "You can update Rust with: rustup update"
        return 0
    fi

    info "Installing Rust (${RUST_VERSION})..."
    warn "This installer is interactive and will prompt for input"

    # Install rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain "${RUST_VERSION}"

    # Source cargo env
    source "$HOME/.cargo/env"

    success "Rust ${RUST_VERSION} installed"

    # Install zellij
    if confirm "Install zellij terminal multiplexer?"; then
        info "Installing zellij via cargo..."
        cargo install zellij
        success "zellij installed"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_rust
fi
