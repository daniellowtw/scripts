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

    local target
    case "$(get_arch)" in
        amd64) target="x86_64-unknown-linux-musl" ;;
        arm64) target="aarch64-unknown-linux-musl" ;;
        armhf)
            # Pi Zero / Pi 1 are ARMv6
            if [[ "$(uname -m)" == "armv6l" ]]; then
                target="arm-unknown-linux-musleabihf"
            else
                target="armv7-unknown-linux-musleabihf"
            fi
            ;;
    esac
    local binary="just-${JUST_VERSION}-${target}.tar.gz"
    local url="https://github.com/casey/just/releases/download/${JUST_VERSION}/${binary}"

    # Download and extract
    info "Downloading from ${url}..."
    curl -fsSL "${url}" -o "/tmp/${binary}"
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
