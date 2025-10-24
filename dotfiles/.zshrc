DISABLE_AUTO_UPDATE="true"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

setopt histignorealldups sharehistory
setopt HIST_NO_STORE            # do not save history commands
setopt HIST_IGNORE_SPACE


HISTSIZE=4096
SAVEHIST=4096
HISTFILE=$HOME/.zsh_history

# Set up prompts
command -v starship > /dev/null && eval "$(starship init zsh)"
if [[ -f $ZSH/oh-my-zsh.sh ]]; then
  # Set name of the theme to load.
  # Look in ~/.oh-my-zsh/themes/
  # Optionally, if you set this to "random", it'll load a random theme each
  # time that oh-my-zsh is loaded.
  #ZSH_THEME="powerlevel10k/powerlevel10k"
  ZSH_THEME="cloud"
  source $ZSH/oh-my-zsh.sh
  # export PS1="[`date +%I:%M`]$PS1"
  export PS1="[%D{%T}]%{$fg[blue]%}%m$PS1"
fi

# You may need to manually set your language environment
# export LANG=en_US.UTF-8
#
# Easier find
f() {
  search=$1
  shift
  find . -iname "*$search*" $@ 2>/dev/null
}

rot13(){
  echo "$@" | tr '[a-m][n-z][A-M][N-Z][0-4][5-9]' '[n-z][a-m][N-Z][A-M][5-9][0-4]'
}

encrypt_aes(){
  echo "$@" | openssl aes-256-cbc -a -salt -in /dev/stdin -out /dev/stdout
}

decrypt_aes(){
  echo "$@" | openssl aes-256-cbc -d -a -in /dev/stdin -out /dev/stdout
}

alias gdb="gdb --quiet"
alias ez="vim ~/.zshrc"
alias rz="source ~/.zshrc"
# N.B will still appear in current session's history.
alias incognito=' unset HISTFILE'

if [[ -f $HOME/.bash_aliases ]]; then
  source $HOME/.bash_aliases
fi

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

source ~/.localdlowrc
