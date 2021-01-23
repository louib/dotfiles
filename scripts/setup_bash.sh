#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

if [ -d "$HOME/git-prompt.sh" ]; then
    cp "$SCRIPT_DIR/../bash/git-prompt.sh" "$HOME/git-prompt.sh"
    echo "✔️ Configured Git Prompt."
else
    echo "✔️ Git Prompt already configured."
fi
