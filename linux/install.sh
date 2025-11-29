#!/usr/bin/env bash

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"

# Component definitions
declare -A COMPONENTS=(
  [1]="APT Packages (ripgrep, curl, jq, gh, git, fzf, vim, htop, zsh)"
  [2]="yq - YAML processor"
  [3]="Neovim - Modern Vim"
  [4]="Rust & Zellij - Rust toolchain and terminal multiplexer"
  [5]="Miniforge - Conda/Mamba package manager"
  [6]="Go - Go programming language"
  [7]="Oh My Zsh - Zsh configuration framework"
  [8]="Docker - Container platform"
  [9]="just - Command runner"
)

declare -A INSTALLER_SCRIPTS=(
  [1]="${SCRIPT_DIR}/lib/installers/apt-packages.sh"
  [2]="${SCRIPT_DIR}/lib/installers/yq.sh"
  [3]="${SCRIPT_DIR}/lib/installers/nvim.sh"
  [4]="${SCRIPT_DIR}/lib/installers/rust.sh"
  [5]="${SCRIPT_DIR}/lib/installers/conda.sh"
  [6]="${SCRIPT_DIR}/lib/installers/golang.sh"
  [7]="${SCRIPT_DIR}/lib/installers/oh-my-zsh.sh"
  [8]="${SCRIPT_DIR}/lib/installers/docker.sh"
  [9]="${SCRIPT_DIR}/lib/installers/just.sh"
)

# Print header
print_header() {
  echo "=========================================="
  echo "  Linux Development Environment Setup"
  echo "=========================================="
  echo ""
  echo "Version configuration: ${SCRIPT_DIR}/versions.conf"
  echo ""
}

# Print menu
print_menu() {
  echo "Available components:"
  echo ""
  for i in $(seq 1 ${#COMPONENTS[@]}); do
    echo "  [$i] ${COMPONENTS[$i]}"
  done
  echo ""
  echo "  [a] Install all components"
  echo "  [q] Quit"
  echo ""
}

# Install component
install_component() {
  local num=$1
  local script="${INSTALLER_SCRIPTS[$num]}"

  if [[ ! -f "$script" ]]; then
    error "Installer script not found: $script"
    return 1
  fi

  echo ""
  info "Running installer: ${COMPONENTS[$num]}"
  echo "----------------------------------------"

  # Source and run the installer
  source "$script"

  echo "----------------------------------------"
  echo ""
}

# Install all components
install_all() {
  info "Installing all components..."
  echo ""

  for i in $(seq 1 ${#COMPONENTS[@]}); do
    install_component "$i"
    sleep 1
  done

  success "All components processed!"
}

# Main interactive loop
main() {
  print_header

  while true; do
    print_menu
    read -p "Select option: " choice

    case "$choice" in
    [1-9])
      install_component "$choice"
      ;;
    a | A)
      install_all
      break
      ;;
    q | Q)
      info "Exiting..."
      exit 0
      ;;
    *)
      warn "Invalid option: $choice"
      ;;
    esac
  done
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
