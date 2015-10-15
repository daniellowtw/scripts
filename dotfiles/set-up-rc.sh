#!/bin/bash

if [ -e ~/.zshrc ]; then
  echo "zshrc detected"
  ln -s .dlowrc ~/.dlowrc
  echo "source ~/.dlowrc" >> ~/.zshrc
else
  echo "copying to bashrc"
  echo "source ~/.dlowrc" >> ~/.bashrc
fi
echo "Loaded zshrc. Please restart shell."
