#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")


install_libhandy () {
    if ! pkg-config --exists "libhandy-1" 2> /dev/null; then
        tmp_dir=$(mktemp -d -t libhandy-XXXXXXXXXX)
        cd "$tmp_dir"

        git clone https://gitlab.gnome.org/GNOME/libhandy.git
        cd libhandy

        apt-get build-dep . -y
        meson build .
        ninja -C build
        ninja -C build install
    else
        echo "✔️  libhandy is already installed."
    fi
}

install_libhandy
