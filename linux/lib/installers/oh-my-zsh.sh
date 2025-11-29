#!/usr/bin/env bash

set -e

# Get script directory and load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        warn "Oh My Zsh is already installed"
        return 0
    fi

    info "Installing Oh My Zsh..."
    warn "This installer is interactive"

    # Install oh-my-zsh
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

    success "Oh My Zsh installed"
}

# Setup zsh as default shell
setup_zsh() {
    if ! command_exists zsh; then
        error "zsh is not installed. Install it first (apt-packages.sh)"
        return 1
    fi

    # Create .zshrc if it doesn't exist
    touch ~/.zshrc

    # Change default shell to zsh
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        info "Setting zsh as default shell..."
        ensure_sudo
        sudo chsh -s "$(which zsh)" "$USER"
        success "Default shell changed to zsh (restart your session to apply)"
    else
        info "zsh is already the default shell"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_zsh
    install_oh_my_zsh
fi
