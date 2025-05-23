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
# FIXME I might want to use home-manager for that, otherwise the settings
# are getting overwritten. 
# See https://nix-community.github.io/home-manager/options.html#opt-programs.bash.historyFileSize
# and https://nix-community.github.io/home-manager/options.html#opt-programs.bash.historySize
HISTSIZE=20000
HISTFILESIZE=$HISTSIZE

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

set -o vi

# FIXME the only reason why this function exists is because the default home-manager config
# added at the end of the generated bashrc file always gives priority to the packages installed
# at the user-level over packages installed at the project level.
reorder_nix_paths () {
    was_removed=0
    # While the path is found at the start of PATH, remove it
    while [[ "$PATH" == "/home/$USER/.nix-profile/bin:"* ]]; do
        was_removed=1
        PATH="${PATH#/home/"$USER"/.nix-profile/bin:}"
    done
    # Add it back at the end if it was removed from the front
    if [ $was_removed -eq 1 ]; then
        PATH="$PATH:/home/$USER/.nix-profile/bin"
    fi
}

# Setting the current directory as the tab's title.
# See https://wiki.archlinux.org/title/Bash/Prompt_customization#Prompts
# for additional Bash customizations.
set_title () {
    CURRENT_DIR=$(basename "$PWD")
    PS1="${PS1}\[\e]2;$CURRENT_DIR\a\]"
    # This should not be in a starship specific function, since this should
    # run whether starship is configured or not.
    set_zellij_tab_name
}

# See https://starship.rs/advanced-config/#change-window-title
# for documentation.
set_title_starship () {
    reorder_nix_paths
    CURRENT_DIR=$(basename "$PWD")
    echo -ne "\033]0; $CURRENT_DIR \007"
    # This should not be in a starship specific function, since this should
    # run whether starship is configured or not.
    set_zellij_tab_name
}

# This function is used only to make sure that the wezterm tab name
# is exactly equal to the zellij short session name, without all the
# prefixes that zellij adds by default.
set_zellij_tab_name () {
    if [ -x "$(command -v wezterm)" ] && [ -x "$(command -v zellij)" ]; then
        if [[ -n "$ZELLIJ_SESSION_NAME" ]]; then
            wezterm cli set-tab-title " $ZELLIJ_SESSION_NAME "
        fi
    fi
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
