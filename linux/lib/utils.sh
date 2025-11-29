#!/usr/bin/env bash

# Shared utility functions for installers

# Get the script directory (works when sourced from different locations)
get_script_dir() {
    if [[ -n "${BASH_SOURCE[0]}" ]]; then
        dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    else
        pwd
    fi
}

# Load versions from versions.conf
load_versions() {
    local script_dir=$(get_script_dir)
    local versions_file="${script_dir}/versions.conf"

    if [[ ! -f "$versions_file" ]]; then
        echo "Error: versions.conf not found at $versions_file" >&2
        exit 1
    fi

    # Source the versions file
    source "$versions_file"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print success message in green
success() {
    echo -e "\033[0;32m✓ $1\033[0m"
}

# Print info message in blue
info() {
    echo -e "\033[0;34m→ $1\033[0m"
}

# Print warning message in yellow
warn() {
    echo -e "\033[0;33m⚠ $1\033[0m"
}

# Print error message in red
error() {
    echo -e "\033[0;31m✗ $1\033[0m" >&2
}

# Check if running as root (for sudo checks)
is_root() {
    [[ $EUID -eq 0 ]]
}

# Ensure sudo is available
ensure_sudo() {
    if ! command_exists sudo; then
        error "sudo is not available"
        exit 1
    fi
}

# Download file with progress
download_file() {
    local url="$1"
    local output="$2"

    if command_exists curl; then
        curl -fsSL -o "$output" "$url"
    elif command_exists wget; then
        wget -q -O "$output" "$url"
    else
        error "Neither curl nor wget is available"
        return 1
    fi
}

# Ask yes/no question (default: yes)
confirm() {
    local prompt="$1"
    local response

    read -p "$prompt [Y/n] " response
    case "$response" in
        [nN][oO]|[nN])
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}
