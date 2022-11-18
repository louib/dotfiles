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

if [[ -n $(diff "$SCRIPT_DIR/../assets/bash/.bashrc" "$HOME/.bashrc") ]]; then
    cp "$SCRIPT_DIR/../assets/bash/.bashrc" ~/.bashrc
    echo "✔️ Configured bashrc."
else
    echo "✔️ bashrc is already configured."
fi
