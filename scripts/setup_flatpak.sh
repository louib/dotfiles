#!/usr/bin/env bash
set -e

die() { echo "$*" 1>&2 ; exit 1; }

if ! command -v flatpak &> /dev/null; then
    die "flatpak is not installed!"
fi

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --user --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
flatpak remote-add --user --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
# flatpak remote-add --user --if-not-exists kde "$SCRIPT_DIR/../assets/kderuntime.flatpakrepo"
# flatpak remote-add --user --if-not-exists freedesktop-sdk https://releases.freedesktop-sdk.io/freedesktop-sdk.flatpakrepo

# TODO we could also add the option to use local flatpakrepo files.
