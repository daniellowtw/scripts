#!/bin/sh
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci 'commit -v'
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.recent "for-each-ref --sort=committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'"
git config --global url."git@github.com:".insteadOf "https://github.com/"
git config --global alias.logd 'log --decorate'


git config --global user.email daniellowtw@gmail.com
git config --global user.name "Daniel Low"

