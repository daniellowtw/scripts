# Redirect Fisher plugin installations away from ~/.config/fish so plugin files
# don't appear as untracked changes in the dotfiles repo. XDG_DATA_HOME
# (~/.local/share) is the right place for installed data on both Linux and Mac.
set -gx fisher_path ~/.local/share/fisher
# Teach fish where to find functions and completions installed by Fisher.
set fish_function_path $fisher_path/functions $fish_function_path
set fish_complete_path $fisher_path/completions $fish_complete_path
# Source any plugin init scripts (e.g. nvm.fish puts env setup in conf.d/).
for file in $fisher_path/conf.d/*.fish
    source $file
end

if status is-interactive
    fish_vi_key_bindings
end

fish_add_path ~/.local/bin ~/.cargo/bin

set -gx EDITOR vim

test -e ~/.dlow.fish && source ~/.dlow.fish

command -v nvim >/dev/null && alias vim=nvim
command -v starship >/dev/null && starship init fish | source
command -v zoxide >/dev/null && zoxide init fish | source
command -v fzf >/dev/null && fzf --fish | source
command -v xplr >/dev/null && alias xp=xplr

function f
    set search $argv[1]
    find . -iname "*$search*" $argv[2..-1] 2>/dev/null
end

function gre
    git recent | fzf | cut -d' ' -f 2 | xargs -I % git co %
end
