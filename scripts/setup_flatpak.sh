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

if flatpak list --app | grep org.keepassxc.KeePassXC &> /dev/null; then
    echo "KeePassXC is already installed."
else
    # Version that includes the ssh-add CLI command
    flatpak install --user https://dl.flathub.org/build-repo/92408/org.keepassxc.KeePassXC.flatpakref
    # flatpak install --user flathub org.keepass.KeePassXC
fi

KPXC_CONFIG_DIR="$HOME/.config/keepassxc"
KPXC_CONFIG_PATH="$KPXC_CONFIG_DIR/keepassxc.ini"
if [[ ! -d "$KPXC_CONFIG_DIR" ]]; then
    mkdir -p "$KPXC_CONFIG_DIR"
fi
cp "$SCRIPT_DIR/../assets/keepassxc/keepassxc.ini" "$KPXC_CONFIG_PATH"

if flatpak list --app | grep org.gnome.Evince &> /dev/null; then
    echo "Evince is already installed."
else
    flatpak install -y --user flathub org.gnome.Evince
fi

if flatpak list --app | grep io.neovim.nvim &> /dev/null; then
    echo "NeoVim is already installed."
else
    flatpak install -y --user flathub io.neovim.nvim
fi

# See the list of extensions here https://github.com/orgs/flathub/repositories?language=&page=1&q=extension&sort=&type=all
# TODO python extension is installed by default?
# flatpak install --user flathub org.freedesktop.Sdk.Extension.node16

# TODO llvm 13 and 14 are already available.
flatpak install --user -y flathub org.freedesktop.Sdk.Extension.llvm12
flatpak install --user -y flathub org.freedesktop.Sdk.Extension.rust-stable

# TODO also add C++ via llvm extension?
# Run as FLATPAK_ENABLE_SDK_EXT=rust-stable,node16,llvm12 flatpak run io.neovim.nvim

# flatpak install --user flathub org.mozilla.Firefox

# flatpak install --user flathub org.mozilla.Thunderbird

flatpak update
