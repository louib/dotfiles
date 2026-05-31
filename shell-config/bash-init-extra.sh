# shellcheck shell=bash
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# This is used to disable an annoying behavior of fzf.
# See https://github.com/junegunn/fzf/issues/3008
# for details.
# It has to be in the init extra section of the bash config, otherwise
# fzf will try to re-configure the bindings after they have been
# disabled.
bind -m vi-command -r '\ec'
bind -m vi-insert -r '\ec'
