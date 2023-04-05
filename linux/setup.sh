#!/usr/bin/env bash

set -eux -o pipefail

# Interactive session to set up software
sudo apt update
sudo apt install -y rg curl rg yq gh build-essential git fzf vim htop zsh

# Create key
# ssh-keygen -t ed25519 -b 4096
# gh auth login


# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

cargo install ripgrep zellij

# Python

# https://github.com/conda-forge/miniforge#mambaforge
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh

# Install go
curl -L -O https://golang.org/dl/go1.20.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.20.2.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# Install zsh and go
touch ~/.zshrc
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh --dry-run
echo "Does it look ok? Ctrl + C to exit if not"
read
sudo sh ./get-docker.sh 
