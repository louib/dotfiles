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

set_title () {
    # FIXME this should basically only remove the path to my projects, if that path
    # exists in the current directory. Everything else should be the full path of the
    # directory.
    CURRENT_DIR=$(basename "$PWD")
    wezterm cli set-tab-title "$CURRENT_DIR"
}

if [ -x "$(command -v starship)" ]; then
    eval "$(starship init zsh)"
fi

if [ -x "$(command -v wezterm)" ]; then
    # See all the other hook functions for zsh here:
    # https://zsh.sourceforge.io/Doc/Release/Functions.html#Hook-Functions
    function chpwd() {
        set_title
    }

    set_title
fi


export CLICOLOR=1
