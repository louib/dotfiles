#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

if [[ -n $(diff "$SCRIPT_DIR/../assets/bash/.inputrc" "$HOME/.inputrc") ]]; then
    cp "$SCRIPT_DIR/../assets/bash/.inputrc" "$HOME/.inputrc"
    echo "✔️ Configured inputrc for readline."
else
    echo "✔️ Readline is already configured."
fi

starship_config_path="$SCRIPT_DIR/../flakes/shell-config/starship.toml"
starship_config_destination="$HOME/.config/starship.toml"
if [[ -n $(diff "$starship_config_path" "$starship_config_destination") ]]; then
    cp "$starship_config_path" "$starship_config_destination"
    echo "✔️ Configured starship."
else
    echo "✔️ Starship is already configured."
fi

bash_rc_path="$SCRIPT_DIR/../flakes/shell-config/bashrc.sh"
if [[ -n $(diff "$bash_rc_path" "$HOME/.bashrc") ]]; then
    cp "$bash_rc_path" ~/.bashrc
    echo "✔️ Configured bashrc."
else
    echo "✔️ bashrc is already configured."
fi
