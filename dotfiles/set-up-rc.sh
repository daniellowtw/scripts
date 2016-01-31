#!/bin/bash

if [ -e ~/.zshrc ]; then
  echo "zshrc detected"
  read -p "This will replace existing config files. Continue (y/n)?" -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$  ]]
  then
    echo "You said no. Bye"
  fi
  echo ln -s $(pwd)/.zshrc ~/.zshrc
  rm -f ~/.zshrc
  ln -s $(pwd)/.zshrc ~/.zshrc
  echo ln -s $(pwd)/.dlowrc ~/.dlowrc
  rm -f ~/.dlowrc
  ln -s $(pwd)/.dlowrc ~/.dlowrc
  echo "source ~/.dlowrc" >> ~/.zshrc
else
  echo "copying to bashrc"
  echo "source ~/.dlowrc" >> ~/.bashrc
fi
echo "Loaded zshrc. Please restart shell."
