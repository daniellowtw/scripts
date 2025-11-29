#!/usr/bin/env bash

set -e

# Get script directory and load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

install_docker() {
    if command_exists docker; then
        warn "Docker is already installed ($(docker --version))"
        return 0
    fi

    info "Installing Docker..."

    # Download Docker install script
    curl -fsSL https://get.docker.com -o get-docker.sh

    # Show dry run
    info "Running Docker installer in dry-run mode first..."
    ensure_sudo
    sudo sh ./get-docker.sh --dry-run

    # Confirm before proceeding
    if ! confirm "Does the dry-run output look OK? Install Docker?"; then
        rm get-docker.sh
        warn "Docker installation cancelled"
        return 1
    fi

    # Install Docker
    sudo sh ./get-docker.sh

    # Add current user to docker group
    sudo usermod -aG docker "$USER"

    # Cleanup
    rm get-docker.sh

    success "Docker installed"
    warn "Log out and back in for docker group membership to take effect"
    info "Or run: newgrp docker"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_docker
fi
