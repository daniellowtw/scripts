#!/bin/bash

if [ -e ~/.i3 ]; then
  echo "i3 detected"
  read -p "This will replace existing config files. Continue (y/n)?" -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$  ]]
  then
    echo "You said no. Bye"
  fi
  echo ln -s $(pwd)/.i3 ~/.i3
  rm -rf ~/.i3
  ln -s $(pwd)/.i3 ~/.i3
  echo "Loaded i3. Please restart shell."
else
  echo "No i3 installed, exiting"
fi
