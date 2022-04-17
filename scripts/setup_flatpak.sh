#!/usr/bin/env bash
set -e

die() { echo "$*" 1>&2 ; exit 1; }

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

if ! command -v flatpak &> /dev/null; then
    die "flatpak is not installed!"
fi

flatpak remote-add --if-not-exists --user flathub "$SCRIPT_DIR/../assets/flatpak/flathub.flatpakrepo"
# Or added directly:
# flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak remote-add --if-not-exists --user flathub-beta "$SCRIPT_DIR/../assets/flatpak/flathub-beta.flatpakrepo"
# Or added directly:
#flatpak remote-add --user --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

flatpak remote-add --if-not-exists --user gnome-nightly "$SCRIPT_DIR/../assets/flatpak/gnome-nightly.flatpakrepo"
# Or added directly:
# flatpak remote-add --user --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo

# flatpak remote-add --user --if-not-exists kde "$SCRIPT_DIR/../assets/kderuntime.flatpakrepo"
# flatpak remote-add --user --if-not-exists freedesktop-sdk https://releases.freedesktop-sdk.io/freedesktop-sdk.flatpakrepo

flatpak install --user flathub org.keepass.KeePassXC
flatpak install --user flathub org.gnome.Evince
# flatpak install --user flathub io.neovim.nvim
# flatpak install --user flathub org.mozilla.Firefox
# flatpak install --user flathub org.mozilla.Thunderbird

flatpak update
