#!/bin/bash

# cd to script dir
cd $(dirname "$0")

source ./lib.sh
warn

OS=$(uname | awk '{print tolower($0)}')

if [[ OS != 'linux' ]]; then
  echo "This script currently only works for linux. Detected your os to be $OS"
  exit 1
fi

if [[ -d ~/bin ]]; then
  echo "Creating ~/bin for tooling binaries"
  mkdir -p ~/bin
fi

download_shfmt() {

  SHFMT_VERSION=2.6.4
  local SHFMT_SUFFIX
  if [[ $(uname -m) =~ "arm" ]]; then
    SHFMT_SUFFIX="arm"
  else
    SHFMT_SUFFIX="amd64"
  fi
  wget https://github.com/mvdan/sh/releases/download/v$SHFMT_VERSION/shfmt_v${SHFMT_VERSION}_${OS}_${SHFMT_SUFFIX} --output-document=~/bin/shfmt
  chmod +x ~/bin/shfmt
  echo "Install shfmt v${SHFMT_VERSION}"
}

download_shfmt
