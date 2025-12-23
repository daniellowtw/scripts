#!/bin/bash

# cd to script dir
cd $(dirname "$0")

source ./lib.sh
warn "This will install software from the internet"

OS=$(uname | awk '{print tolower($0)}')

if [[ -d ~/bin ]]; then
	echo "Creating ~/bin for tooling binaries"
	mkdir -p ~/bin
fi

download_shfmt() {

	SHFMT_VERSION=3.12.0
	local SHFMT_SUFFIX
	if [[ $(uname -m) =~ "arm" ]]; then
		SHFMT_SUFFIX="arm64"
	else
		SHFMT_SUFFIX="amd64"
	fi
	curl -L https://github.com/mvdan/sh/releases/download/v$SHFMT_VERSION/shfmt_v${SHFMT_VERSION}_${OS}_${SHFMT_SUFFIX} --output ~/.local/bin/shfmt
	chmod +x ~/.local/bin/shfmt
	echo "Install shfmt v${SHFMT_VERSION}"
}

download_shfmt

# Install Homebrew
if [[ $(command -v brew) == "" ]]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
