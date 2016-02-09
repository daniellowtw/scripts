#!/bin/sh

VERSION=1.5.3
if [ -e /lib/ld-linux-armhf.so.3 ] || [ -e /lib/ld-linux-armel.so.3 ]; then
	echo "Multi arch detected. Downloading go $VERSION"
	echo wget http://dave.chney.net/paste/go$VERSION.linux-arm.tar.gz
	wget http://dave.chney.net/paste/go$VERSION.linux-arm.tar.gz
else
	echo "Multi arch not detected. Not sure what to download. Exiting
	exit
fi

tar xzf go$VERSION.linux-arm.tar.gz




