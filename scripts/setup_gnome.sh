#!/usr/bin/env bash
set -e

# Configuring gnome terminal.
dconf write /org/gnome/terminal/legacy/keybindings/find "'<Primary>slash'"
dconf write /org/gnome/terminal/legacy/keybindings/find-next "'<Primary>n'"
dconf write /org/gnome/terminal/legacy/keybindings/find-previous "'<Primary>p'"

# Configure application navigation
dconf write /org/gnome/desktop/wm/keybindings/switch-applications "['<Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-applications-backward "['<Shift><Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-windows "@as []"
dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward "@as []"

dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
echo "✔️ Configured gtk dark theme"

dconf write /org/gnome/desktop/screensaver/logout-delay 7200

# For some reason the "Power Off" mode is not called "power-off" or "poweroff" in dconf,
# whereas all the other modes (suspend, hibernate, etc), are called the equivalent in dconf.
dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'interactive'"
