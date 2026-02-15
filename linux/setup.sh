#!/usr/bin/env bash

set -eux -o pipefail

# Interactive session to set up software
sudo apt update
sudo apt install -y ripgrep curl jq gh build-essential git fzf vim htop zsh
touch ~/.zshrc
sudo chsh -s $(which zsh)

if [[ $(command -v yq) ]]; then
  echo "Bat is already installed"
else
  VERSION=v4.2.0
  BINARY=yq_linux_amd64
  wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - |
    tar xz &&
    sudo mv ${BINARY} /usr/bin/yq
fi

if [[ $(command -v nvim) ]]; then
  echo "nvim is already installed"
else
  curl -LO https://github.com/neovim/neovim/releases/download/v0.11.6/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  rm nvim-linux-x86_64.tar.gz
fi

# Create key
# ssh-keygen -t ed25519 -b 4096
# gh auth login

# Install rust
if [[ $(command -v rustup) ]]; then
  echo "Rust is already installed"
else
  echo "Installing Rust"
  # Interactive
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  $HOME/.local/bin/cargo install zellij
fi

# Python

if [[ $(command -v conda) ]]; then
  echo "Conda is already installed"
else
  # https://github.com/conda-forge/miniforge#mambaforge
  curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
  bash Miniforge3-$(uname)-$(uname -m).sh
  rm Miniforge3-$(uname)-$(uname -m).sh
fi

# Install go
if [[ $(command -v go) ]]; then
  echo "Go is already installed"
else
  echo "Installing Go"
  curl -L -O https://go.dev/dl/go1.22.4.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh my zsh is already installed"
else
  sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
fi

if [[ $(command -v docker) ]]; then
  echo "Docker is already installed"
else
  # Install docker
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh ./get-docker.sh --dry-run
  echo "Does it look ok? Ctrl + C to exit if not"
  read
  sudo sh ./get-docker.sh
  sudo usermod -aG docker $USER
  rm get-docker.sh
fi
