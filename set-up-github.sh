#!/usr/bin/env bash

git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci 'commit -v'
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.recent "for-each-ref --sort=committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'"
git config --global url."git@github.com:".insteadOf "https://github.com/"
git config --global alias.logd 'log --decorate'
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

echo "Do you want to set your user.name and user.email to your gmail? [y/n]"
read res
if [[ $res == "y" ]]; then
  git config --global user.email daniellowtw@gmail.com
  git config --global user.name "Daniel Low"
  echo "Done. Bye"
else
  echo "You said $res. Bye"
fi
