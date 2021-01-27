#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

if [ -d "$HOME/git-prompt.sh" ]; then
    cp "$SCRIPT_DIR/../assets/bash/git-prompt.sh" "$HOME/git-prompt.sh"
    echo "✔️ Configured Git Prompt."
else
    echo "✔️ Git Prompt already configured."
fi

if [[ ! -f "$HOME/.inputrc" ]]; then
    cp "$SCRIPT_DIR/../assets/bash/.inputrc" "$HOME/.inputrc"
    echo "✔️ Copied inputrc for readline config."
fi
