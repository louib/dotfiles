# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x "$(command -v lesspipe)" ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x "$(command -v dircolors)" ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'

##### Custom configuration section #####
set -o vi

alias vi="nvim"
alias vim="nvim"
export VISUAL="nvim"

# checkout the default git branch.
# (git checkout default)
function gcd () {
    # TODO I have this duplicated below. Should be extracted into a function.
    # Taken from https://stackoverflow.com/questions/28666357/git-how-to-get-default-branch
    default_branch=$(git remote show origin | grep "HEAD branch" | cut -d ":" -f 2 | xargs)
    git checkout "$default_branch"
}
# git commit amend
function gca () {
    git commit --amend --no-edit
}
# git new branch
function gnb () {
    git checkout -b "$1"
}
# a simple git checkout
function gco () {
    git checkout "$1"
}
alias gst="git status"
alias gdf="git diff"
function grb () {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    git fetch -a
    git rebase "origin/$current_branch"
}
# Rebase on the default branch
function grm () {
    # Taken from https://stackoverflow.com/questions/28666357/git-how-to-get-default-branch
    default_branch=$(git remote show origin | grep "HEAD branch" | cut -d ":" -f 2 | xargs)
    git pull --rebase origin "$default_branch"
}
function gp () {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    git push origin "$current_branch"
}
function gpf () {
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    git push --force-with-lease origin "$current_branch"
}

# Cargo stuff
alias ci="cargo install --force --path ."
alias cb="cargo build"
alias ct="cargo test"
alias cf="find . -name '*.rs' -exec rustfmt {} \;"
export RUSTFLAGS="$RUSTFLAGS -A warnings"
# Default commands for a meson and ninja build.
function meb () {
    meson . _build
    ninja -C _build
}
function mei () {
    meson . _build
    ninja -C _build
    ninja -C _build install
}

# Nix stuff
alias nix-search="nix-env -qa"
alias ndv="nix develop ."
alias nfc="nix flake check"

# Setting the current directory as the tab's title.
# See https://wiki.archlinux.org/title/Bash/Prompt_customization#Prompts
# for additional Bash customizations.
set_title () {
    CURRENT_DIR=$(basename "$PWD")
    PS1="${PS1}\[\e]2;$CURRENT_DIR\a\]"
}
# See https://starship.rs/advanced-config/#change-window-title
# for documentation.
set_title_starship () {
    CURRENT_DIR=$(basename "$PWD")
    echo -ne "\033]0; $CURRENT_DIR \007"
}
starship_precmd_user_func="set_title_starship"

get_prompt () {
    PS1=""
    SUBSHELL=""
    if [[ -n "$FENV_IS_IN_SANDBOX" ]]; then
        SUBSHELL="[fenv]"
    elif [[ -n "$IN_NIX_SHELL" ]]; then
        SUBSHELL="[nix]"
    fi
    # This adds the time as [22:22:22]
    PS1="${PS1}\[\e[m\]\[\e[35m\][\[\e[m\]\t\[\e[35m\]]"
    # This adds the directory as [~/Projects/fenv]
    PS1="${PS1}\[\e[m\]\[\e[35m\][\[\e[m\]\w\[\e[35m\]]"
    # This adds the fenv sandbox prompt
    PS1="${PS1}\[\e[m\]\[\e[32m\]$SUBSHELL"
    # This adds the ending $ char.
    PS1="${PS1}\[\e[m\]\[\e[91m\]\\$\[\e[m\] "

    # Setting the terminal title everytime the prompt gets updated.
    set_title
}
PROMPT_COMMAND=get_prompt

# Replace cd by an alias that will also update the title after
# changing the directory.
function cd () {
  if [ $# -eq 1 ]; then
    command cd -- "$1"
    set_title
  else
    echo "Need a directory to cd to!"
  fi
}

export QT_LOGGING_RULES="*.debug=false"

# function to send an emojified message to git commit
function emocommit () { emojify "$1" | git commit -n -F -; }
# function to search emojies
function emosearch () { emojify --list | grep "$1"; }
# function to clip an emoji
function emoclip () {
    # Taken from https://unix.stackexchange.com/questions/202891/how-to-know-whether-wayland-or-x11-is-being-used
    session_id=$(awk '/tty/ {print $1}' <(loginctl))
    session_type=$(loginctl show-session "$session_id" -p Type | awk -F= '{print $2}')
    emoji_best_match=$(emojify --list | grep ":$1:" | head -n 1 | tr -d '\n')
    emoji_character=$(echo "$emoji_best_match" | sed 's/:.*://' | sed 's/ //g')
    if [[ -z "$emoji_best_match" ]]; then
        echo "No emoji matching $1"
        return
    fi
    echo "Clipping $emoji_best_match"

    if [[ "$session_type" == "x11" ]]; then
        echo "$emoji_character" | tr -d '\n' | xclip -i -selection clipboard;
    else
        # FIXME wl-copy add a newline to the output, even though there is none in the input. There is an option
        # for no newline on wl-paste, but not on wl-copy. See https://github.com/bugaevc/wl-clipboard/issues/63
        echo "$emoji_character" | tr -d '\n' | wl-copy;
    fi
}

# Search the current project for the specific term
function sp () {
    grep \
        --binary-files=without-match \
        --recursive \
        --line-number \
        --color=always \
        --exclude-dir=.git/ \
        --exclude-dir=node_modules/ \
        --exclude-dir=target/ \
        --exclude-dir=dist/ \
        --exclude-dir=build/ \
        --exclude-dir=_build/ \
        "$1"
}

# For find and replace
# Usage example:
# sar "s/allo/Allo/g"
function far () {
    find . -type f -exec sed -i "$1" {} +
}

if [[ -f "$HOME/.bash_profile" ]]; then
    . "$HOME/.bash_profile"
fi

[ -x "$(command -v id)" ] && export SSH_AUTH_SOCK=/var/run/user/$(id -u)/gnupg/S.gpg-agent.ssh

if [ -x "$(command -v starship)" ]; then
    eval "$(starship init bash)"
fi
