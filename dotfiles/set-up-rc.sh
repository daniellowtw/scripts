#!/bin/bash

function symlink {
  echo rm -f ~/$1
  rm -f ~/$1
  echo ln -s $(pwd)/$1 ~/$1
  ln -s $(pwd)/$1 ~/$1
}

  read -p "This will replace existing config files. Continue (y/n)?" -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$  ]]
  then
    echo "You said no. Bye"
  fi

  symlink ".dlowrc"
  symlink ".zshrc"

# make blank localdlowrc if it doesn't exist
if [ ! -e ~/.localdlowrc ]; then
  echo "creating localdlowrc for local stuff"
  touch ~/.localdlowrc
fi

if [ -e ~/.zshrc ]; then
  echo "zshrc detected"
  symlink ".zshrc"
  echo "source ~/.dlowrc" >> ~/.zshrc
else
  echo "No zshrc, copying to bashrc"
  echo "source ~/.dlowrc" >> ~/.bashrc
fi
echo "Loaded zshrc. Please restart shell."
