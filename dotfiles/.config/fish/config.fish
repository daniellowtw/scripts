if status is-interactive
    fish_vi_key_bindings
    # Commands to run in interactive sessions can go here
end

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
