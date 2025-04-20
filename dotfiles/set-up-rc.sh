#!/usr/bin/env bash

# cd to script dir
cd $(dirname "$0")

source ./lib.sh
warn
# make blank localdlowrc if it doesn't exist
if [[ ! -e ~/.localdlowrc ]]; then
  echo "creating localdlowrc for local stuff"
  cp .localdlowrc ~/.localdlowrc
fi

if [[ -e ~/.zshrc ]]; then
  echo "zshrc detected"
  symlink ".zshrc"
  echo "source ~/.localdlowrc" >>~/.zshrc
else
  echo "No zshrc, copying to bashrc"
  echo "source ~/.localdlowrc" >>~/.bashrc
fi
echo "Loaded zshrc. Please restart shell."
