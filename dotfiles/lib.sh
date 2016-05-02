symlink() {
  echo rm -rf ~/$1
  rm -rf ~/$1
  echo ln -s $(pwd)/$1 ~/$1
  ln -s $(pwd)/$1 ~/$1
}

warn() {
  read -p "This will replace existing config files. Continue (y/n)?" -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$  ]]
  then
    echo "You said no. Bye."
  fi
}
