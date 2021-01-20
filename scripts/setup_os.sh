#!/usr/bin/env bash
set -e

die() { echo "$*" 1>&2 ; exit 1; }

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

if ! command -v nvim &> /dev/null; then
    # Main programs.
    apt-get install -y \
      bash-completion \
      cryptsetup \
      curl \
      evince \
      gnome-tweak-tool \
      gnome-terminal \
      git \
      git-core \
      dconf-cli \
      dconf-editor \
      neovim \
      net-tools \
      python3 \
      python3-pip \
      python3-venv \
      pwgen \
      shellcheck \
      keepassxc \
      thunderbird \
      ttf-bitstream-vera \
      vim \
      wl-clipboard
    echo "✔️  Installed main OS packages."
else
    echo "✔️  Main OS packages already installed."
fi
