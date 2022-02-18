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
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

##### Custom configuration section #####
set -o vi
export VISUAL=vi

alias vi="nvim"
alias vim="nvim"

# checkout the default git branch.
# (git checkout default)
function gcd () {
    # TODO I have this duplicated below. Should be extracted into a function.
    # Taken from https://stackoverflow.com/questions/28666357/git-how-to-get-default-branch
    default_branch=$(git remote show origin | grep "HEAD branch" | cut -d ":" -f 2 | xargs)
    git checkout "$default_branch"
}
function gnb () {
    git checkout -b "$1"
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
    git push -f origin "$current_branch"
}

# Cargo stuff
alias ci="cargo install --force --path ."
alias cb="cargo build"
alias ct="cargo test"
alias cf="find . -name '*.rs' -exec rustfmt {} \;"
export PATH="$PATH:$HOME/.cargo/bin"
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

# Setting the current directory as the tab's title.
# See https://wiki.archlinux.org/title/Bash/Prompt_customization#Prompts
# for additional Bash customizations.
set_title () {
    CURRENT_DIR=$(basename "$PWD")
    PS1="${PS1}\[\e]2;$CURRENT_DIR\a\]"
}

source ~/git-prompt.sh
# From https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh:
# In addition, if you set GIT_PS1_SHOWDIRTYSTATE to a nonempty value,
# unstaged (*) and staged (+) changes will be shown next to the branch
# name.
export GIT_PS1_SHOWDIRTYSTATE=1

get_prompt () {
    PS1=""
    FENV_PROMPT=""
    if [[ -n "$FENV_IS_IN_SANDBOX" ]]; then
        FENV_PROMPT="[fenv sandbox]"
    fi
    # This adds the time as [22:22:22]
    PS1="${PS1}\[\e[m\]\[\e[35m\][\[\e[m\]\t\[\e[35m\]]"
    # This adds the directory as [~/Projects/fenv]
    PS1="${PS1}\[\e[m\]\[\e[35m\][\[\e[m\]\w\[\e[35m\]]"
    # This adds the git prompt as [branch_name *]
    PS1="${PS1}\[\e[m\]\[\e[95m\]$(__git_ps1 '[%s]')"
    # This adds the fenv sandbox prompt
    PS1="${PS1}$FENV_PROMPT"
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
        --exclude-dir=.flatpak-builder/ \
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

# FIXME this is because of a bug in Ubuntu 20.04 where the mapping Caps Lock -> Esc does not work.
function rmap () {
    dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:swapescape', 'grp:win_space_toggle']"
    dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape', 'grp:win_space_toggle']"
}
rmap
