#!/bin/bash
source ./lib.sh
warn
if [ -e ~/.i3 ]; then
  echo "i3 detected"
  symlink ".i3"
  echo "Loaded i3. Please restart shell."
else
  echo "No i3 installed, exiting"
fi
