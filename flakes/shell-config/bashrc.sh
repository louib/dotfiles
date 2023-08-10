# shellcheck shell=bash
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=20000
HISTFILESIZE=$HISTSIZE

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    if test -r ~/.dircolors; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi

    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

set -o vi

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

get_prompt () {
    PS1=""
    SUBSHELL=""
    if [[ -n "$IN_NIX_SHELL" ]]; then
        SUBSHELL="[nix]"
    fi
    # This adds the time as [22:22:22]
    PS1="${PS1}\[\e[m\]\[\e[35m\][\[\e[m\]\t\[\e[35m\]]"
    # This adds the directory as [~/Projects/dir]
    PS1="${PS1}\[\e[m\]\[\e[35m\][\[\e[m\]\w\[\e[35m\]]"
    # This adds the subshells (nix, venv, etc) to the prompt
    PS1="${PS1}\[\e[m\]\[\e[32m\]$SUBSHELL"
    # This adds the ending $ char.
    PS1="${PS1}\[\e[m\]\[\e[91m\]\\$\[\e[m\] "

    # Setting the terminal title everytime the prompt gets updated.
    set_title
}

# Replace cd by an alias that will also update the title after
# changing the directory.
function cd () {
  if [ $# -eq 1 ]; then
    command cd -- "$1" || return
    set_title
  else
    echo "Need a directory to cd to!"
  fi
}

if [ -x "$(command -v id)" ]; then
    user_id=$(id -u)
    export SSH_AUTH_SOCK=/var/run/user/${user_id}/gnupg/S.gpg-agent.ssh
fi

if [ -x "$(command -v starship)" ]; then
    export starship_precmd_user_func="set_title_starship"
    # Here we use the PROMPT_COMMAND not to set the prompt, but to set the title
    # of the terminal.
    PROMPT_COMMAND=set_title_starship
    eval "$(starship init bash)"
else
    PROMPT_COMMAND=get_prompt
fi

# I use this to make sure that the history is synced across my terminal
# tabs. The last exit code has to be preserved in order to feed to starship,
# otherwise the success/failure character won't display correctly.
function refresh_bash_history () {
    last_exit_code=$?
    history -a
    history -c
    history -r
    return $last_exit_code
}

PROMPT_COMMAND="refresh_bash_history; $PROMPT_COMMAND"
