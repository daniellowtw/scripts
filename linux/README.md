# Linux Development Environment Setup

Modular installer for setting up a Linux development environment.

## Quick Start

### Interactive Installation

Run the main installer with an interactive menu:

```bash
./install.sh
```

This will show you a menu where you can select individual components to install or install everything at once.

### Individual Component Installation

Run individual installer scripts directly:

```bash
# Install just Go
./lib/installers/golang.sh

# Install just Docker
./lib/installers/docker.sh

# Install APT packages
./lib/installers/apt-packages.sh
```

## Available Components

1. **APT Packages** - Core development tools (ripgrep, curl, jq, gh, git, fzf, vim, htop, zsh)
2. **yq** - YAML processor
3. **Neovim** - Modern Vim editor
4. **Rust** - Rust toolchain via rustup (includes zellij)
5. **Miniforge** - Conda/Mamba package manager
6. **Go** - Go programming language
7. **Oh My Zsh** - Zsh configuration framework
8. **Docker** - Container platform

## Version Management

All software versions are centrally managed in `versions.conf`. Edit this file to update versions:

```bash
# versions.conf
YQ_VERSION=v4.44.3
NVIM_VERSION=v0.10.2
MINIFORGE_VERSION=24.11.0-0
GO_VERSION=1.23.4
RUST_VERSION=stable
```

After updating versions, re-run the installer to upgrade to the new versions.

## Project Structure

```
.
├── install.sh              # Main interactive installer
├── versions.conf           # Version configuration
├── lib/
│   ├── utils.sh           # Shared utility functions
│   └── installers/        # Individual installer scripts
│       ├── apt-packages.sh
│       ├── yq.sh
│       ├── nvim.sh
│       ├── rust.sh
│       ├── conda.sh
│       ├── golang.sh
│       ├── oh-my-zsh.sh
│       └── docker.sh
└── setup.sh               # Legacy installer (deprecated)
```

## Adding New Components

To add a new component:

1. Create a new installer script in `lib/installers/`
2. Follow the template of existing installers
3. Source `lib/utils.sh` for helper functions
4. Load versions with `load_versions` if needed
5. Add the component to `install.sh` menu
6. Update `versions.conf` if it downloads from GitHub

## Example Installer Template

```bash
#!/usr/bin/env bash

set -e

# Get script directory and load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
load_versions

install_my_tool() {
    if command_exists my_tool; then
        warn "my_tool is already installed"
        return 0
    fi

    info "Installing my_tool..."
    # Installation steps here
    success "my_tool installed"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_my_tool
fi
```

## Notes

- Most installers check if software is already installed before proceeding
- Some installers (Rust, Conda, Oh My Zsh, Docker) are interactive and will prompt for input
- After installing Docker or changing default shell, you may need to log out and back in
- All installers can be run standalone or via the main menu
