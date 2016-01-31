#!/bin/bash

if [ ! -e ~/.vim/bundle/Vundle.vim ]; then
  echo git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

  read -p "This will replace existing config files. Continue (y/n)?" -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$  ]]
  then
    echo "You said no. Bye"
  fi
  echo ln -s $(pwd)/.vimrc ~/.vimrc
  rm -f ~/.vimrc
  ln -s $(pwd)/.vimrc ~/.vimrc
  echo "Please run BundleInstall inside vim"
