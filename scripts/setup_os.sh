#!/usr/bin/env bash
set -e

die() { echo "$*" 1>&2 ; exit 1; }

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

if ! command -v shellcheck &> /dev/null; then
    # Main programs.
    apt-get install -y \
      bash-completion \
      build-essential \
      meson \
      cryptsetup \
      curl \
      gnome-tweaks \
      gnome-terminal \
      flatpak \
      flatpak-builder \
      git \
      git-core \
      dconf-cli \
      dconf-editor \
      net-tools \
      pwgen \
      shellcheck \
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

if ! command -v keepassxc-cli &> /dev/null; then
    # FIXME this could be installed at the user level.
    echo "#!/usr/bin/env bash" > /usr/local/bin/keepassxc-cli
    echo 'flatpak run --user org.keepassxc.KeePassXC cli "$@"' >> /usr/local/bin/keepassxc-cli
    chmod +x /usr/local/bin/keepassxc-cli
    echo "✔️ Installing alias for keepassxc-cli."
else
    echo "✔️ alias for keepassxc-cli already installed."
fi
