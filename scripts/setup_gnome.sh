#!/usr/bin/env bash
set -e

# Configuring gnome terminal.
dconf write /org/gnome/terminal/legacy/default-show-menubar false
dconf write /org/gnome/terminal/legacy/theme-variant "'dark'"
dconf write /org/gnome/terminal/legacy/keybindings/prev-tab "'<Primary>h'"
dconf write /org/gnome/terminal/legacy/keybindings/next-tab "'<Primary>l'"
dconf write /org/gnome/terminal/legacy/keybindings/new-tab "'<Primary>t'"
dconf write /org/gnome/terminal/legacy/keybindings/full-screen "'<Primary>f'"
dconf write /org/gnome/terminal/legacy/keybindings/find "'<Primary>slash'"
dconf write /org/gnome/terminal/legacy/keybindings/find-next "'<Primary>n'"
dconf write /org/gnome/terminal/legacy/keybindings/find-previous "'<Primary>p'"

# Configure application navigation
dconf write /org/gnome/desktop/wm/keybindings/switch-applications "['<Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-applications-backward "['<Shift><Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-windows "@as []"
dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward "@as []"

# FIXME this does not work so far...
dconf write /org/gnome/desktop/media-handling/autorun-never true

# FIXME I think this is broken, the --maximize option no longer exists...
if [[ ! -f "$HOME/.local/share/applications/org.gnome.Terminal.desktop" ]]; then
    mkdir -p ~/.local/share/applications/
    cp /usr/share/applications/org.gnome.Terminal.desktop ~/.local/share/applications/
    # Note that you must not change the TryExec value, as it's used for different purposes that might
    # make the desktop application unavailable. aka if the app fails the TryExec, the app won't be
    # displayed to the user.
    sed -i "s/^Exec=gnome-terminal$/Exec=gnome-terminal --maximize/g" ~/.local/share/applications/org.gnome.Terminal.desktop
    desktop-file-validate ~/.local/share/applications/org.gnome.Terminal.desktop
    update-desktop-database ~/.local/share/applications
    echo "✔️ Gnome terminal is now configured to open maximized"
else
    echo "✔️ Gnome terminal is already configured to open maximized"
fi

# TODO for some reason the profile name is always the same.
# If it ever changes, it would be possible to get it using
# dconf dump / | grep legacy/profiles
# And some sed command.
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-system-font false
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/font "'Monospace 14'"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/audible-bell false
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/scrollback-unlimited true

dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-theme-colors false
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-theme-background false
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-transparent-background false
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/use-theme-transparency false
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/background-transparency-percent "0"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/background-color "'rgb(42,47,48)'"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/foreground-color "'#d1d1ddddeaea'"
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/palette "'#21212d2d3a3a:#686835353838:#383868683535:#686866663535:#353538386868:#666635356868:#353568686666:#90909d9da9a9:#565662626f6f:#e1e1c4c4c5c5:#c5c5e1e1c4c4:#e1e1dfdfc4c4:#c4c4c5c5e1e1:#dfdfc4c4e1e1:#c4c4e1e1dfdf:#d1d1ddddeaea'"
echo "✔️ Configured Gnome terminal"

# Configuring gnome light mode.
dconf write /org/gnome/settings-daemon/plugins/color/night-light-enabled true
dconf write /org/gnome/settings-daemon/plugins/color/night-light-schedule-automatic false
dconf write /org/gnome/settings-daemon/plugins/color/night-light-schedule-from 0.0
dconf write /org/gnome/settings-daemon/plugins/color/night-light-schedule-to 23.983333333333277
dconf write /org/gnome/settings-daemon/plugins/color/night-light-temperature "uint32 2200"
echo "✔️ Configured Gnome light mode"

# Configuring additional keyboard behavior
# Menu is easier to use than windows, because some laptops don't even have a right windows key!
dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape', 'grp:win_space_toggle']"
echo "✔️ Configured additional keyboard behavior"

dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
echo "✔️ Configured gtk dark theme"

dconf write /org/gnome/desktop/peripherals/touchpad/natural-scroll false
echo "✔️ Configured mouse scrolling direction"

dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'nothing'"
dconf write /org/gnome/desktop/screensaver/logout-delay 7200

dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false
# FIXME the firefox_firefox entry is from ubuntu22.04. Not sure why it was renamed,
# maybe because of snap?
dconf write /org/gnome/shell/favorite-apps "[\
  'firefox-esr.desktop', \
  'firefox.desktop', \
  'firefox_firefox.desktop', \
  'org.gnome.Nautilus.desktop', \
  'org.gnome.Terminal.desktop', \
  'org.keepassxc.KeePassXC.desktop', \
  'thunderbird.desktop' \
]"
echo "✔️ Configured Gnome shell"

dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'ca')]"
echo "✔️ Configured available languages."

# For some reason the "Power Off" mode is not called "power-off" or "poweroff" in dconf,
# whereas all the other modes (suspend, hibernate, etc), are called the equivalent in dconf.
dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'interactive'"
