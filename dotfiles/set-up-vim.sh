#!/bin/bash
source ./lib.sh

warn
if [[ ! -e ~/.vim/bundle/Vundle.vim ]]; then
	echo Vundle not found. Installing vundle...
	echo git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  echo Installed Vundle
fi
symlink ".vimrc"

echo "Please run BundleInstall inside vim"
