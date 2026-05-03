#!/usr/bin/env bash

cd $(dirname "$0")

source ./lib.sh
warn "This will install fish and replace ~/.config/fish."

OS=$(uname | awk '{print tolower($0)}')

install_fish() {
  if command -v fish >/dev/null; then
    echo "fish already installed: $(fish --version)"
    return
  fi
  if [[ "$OS" == "darwin" ]]; then
    brew install fish
  elif [[ "$OS" == "linux" ]]; then
    sudo apt-get install -y fish
  else
    echo "Unsupported OS: $OS"
    exit 1
  fi
}

set_default_shell() {
  FISH_PATH=$(command -v fish)
  if grep -qF "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH already in /etc/shells"
  else
    echo "$FISH_PATH" | sudo tee -a /etc/shells
  fi
  chsh -s "$FISH_PATH"
}

install_fish

mkdir -p ~/.config
symlink ".config/fish"

echo "Bootstrapping Fisher and installing plugins..."
# fisher_path must be set here too so Fisher installs plugins to the right place
# during bootstrap, before config.fish has been sourced in a real session.
fish -c "set -gx fisher_path ~/.local/share/fisher; curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher update"

read -p "Set fish as default shell? (y/n)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  set_default_shell
fi

echo "Done. Restart your shell or run: exec fish"
