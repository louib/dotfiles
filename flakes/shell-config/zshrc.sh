# shellcheck shell=bash

# Have a look at https://github.com/softmoth/zsh-vim-mode at some point, to get better
# bindings for vim zsh.
bindkey -v

# Have a look at all the bindings at https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets
bindkey ^R history-incremental-search-backward
bindkey ^S history-incremental-search-forward

# This is required to disable fzf from entering cd searching mode everytime I reset the shell with
# `Esc + c`
bindkey -r '\ec'
bindkey -M vicmd -r '\ec'
bindkey -M viins -r '\ec'

if [ -x "$(command -v starship)" ]; then
    eval "$(starship init zsh)"
fi

export CLICOLOR=1
