#!/usr/bin/env bash
set -e

die() { echo "$*" 1>&2 ; exit 1; }

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

if ! command -v nvim &> /dev/null; then
    # Main programs.
    apt-get install -y \
      bash-completion \
      build-essential \
      meson \
      cryptsetup \
      curl \
      gnome-tweak-tool \
      gnome-terminal \
      flatpak \
      flatpak-builder \
      git \
      git-core \
      dconf-cli \
      dconf-editor \
      # TODO migrate this to a flatpak app
      neovim \
      net-tools \
      # TODO do I really need python always? Maybe put
      # that in a container.
      python3 \
      python3-pip \
      python3-venv \
      pwgen \
      ripgrep \
      shellcheck \
      # TODO move that to a flatpak app.
      thunderbird \
      ttf-bitstream-vera \
      wl-clipboard
    echo "✔️  Installed main OS packages."
else
    echo "✔️  Main OS packages already installed."
fi

if ! command -v emojify &> /dev/null; then
    echo "✔️ Installing emojify from GitHub"
    curl https://raw.githubusercontent.com/mrowa44/emojify/6dc2c1df9a484cf01e7f48e25a1e36e328c32816/emojify -o ./emojify
    emojify_checksum=$(sha256sum ./emojify | cut -d ' ' -f1)
    if [[ "$emojify_checksum" != "6ab45a84b7441f802e8a8e6f0979c06043130fad080e5a02c5d8e4d8a32d85ae" ]]; then
        die "Checksum validation failed for emojify."
    else
        echo "✔️ Validated checksum for emojify."
    fi
    install emojify /usr/local/bin/
    rm ./emojify
    echo "✔️ Installed emojify from GitHub"
else
    echo "✔️ emojify is already installed."
fi
