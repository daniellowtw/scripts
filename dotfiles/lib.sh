symlink() {
  echo rm -rf ~/$1
  rm -rf ~/$1
  echo ln -s $(pwd)/$1 ~/$1
  ln -s $(pwd)/$1 ~/$1
}

warn() {
  prompt=${1:-"This will replace existing config files"}
  read -p "$prompt Continue (y/n)?" -n 1 -r
  echo # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "You said no. Bye."
    exit 1
  fi
}
