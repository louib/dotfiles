#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

input_rc_path="$SCRIPT_DIR/../flakes/shell-config/.inputrc"
if [[ -n $(diff "$input_rc_path" "$HOME/.inputrc") ]]; then
    cp "$input_rc_path" "$HOME/.inputrc"
    echo "✔️ Configured inputrc for readline."
else
    echo "✔️ Readline is already configured."
fi

starship_config_path="$SCRIPT_DIR/../flakes/shell-config/starship.toml"
starship_config_destination="$HOME/.config/starship.toml"
if [[ ! -f "$starship_config_destination" ]] || [[ -n $(diff "$starship_config_path" "$starship_config_destination") ]]; then
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
