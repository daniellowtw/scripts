# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="cloud"
DISABLE_AUTO_UPDATE="true"
plugins=(git debian tmux)

if [[ -f $ZSH/oh-my-zsh.sh ]]; then
  source $ZSH/oh-my-zsh.sh
fi

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

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

if [[ -f $HOME/.bash_aliases ]]; then
  source $HOME/.bash_aliases
fi
# export PS1="[`date +%I:%M`]$PS1"
export PS1="[%D{%T}]%{$fg[blue]%}%m$PS1"

###
# Gcloud stuff
###

# The next line updates PATH for the Google Cloud SDK.
# source '/home/daniel/soft/google-cloud-sdk/path.zsh.inc'

# The next line enables shell command completion for gcloud.
# source '/home/daniel/soft/google-cloud-sdk/completion.zsh.inc'
source ~/.localdlowrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export DOCKER_HOST=tcp://localhost:2375

# Have timestamp for history file.
export HISTTIMEFORMAT="%F %T "

# export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
