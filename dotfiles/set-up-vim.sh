#!/bin/bash
source ./lib.sh

if $(command -v nvim >/dev/null); then
  warn "Installing for nvim"
  echo Symlinked nvim directory
  rm -rf ~/.config/nvim
  ln -s $(pwd)/../nvim ~/.config/nvim
  echo "Please open nvim"

else
  warn "Installing for vim"
  if [[ ! -e ~/.vim/bundle/Vundle.vim ]]; then
    echo Vundle not found. Installing vundle...
    echo git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    echo Installed Vundle
  fi
  symlink ".vimrc"
  echo "Please run BundleInstall inside vim"
fi
