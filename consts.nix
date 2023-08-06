rec {
  # This list is derived from
  # https://github.com/numtide/flake-utils/blob/5aed5285a952e0b949eb3ba02c12fa4fcfef535f/default.nix#L3
  # from which I removed the Darwin systems.
  DEFAULT_SYSTEMS = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  DEFAULT_LOCALE = {
    name = "en_CA.UTF-8";
    ticker = "en";
    gnome_input_name = "us";
  };

  LOCALES = [
    DEFAULT_LOCALE
    {
      name = "fr_CA.UTF-8";
      ticker = "ca";
      gnome_input_name = "ca";
    }
  ];

  # We need to call a home-manager function to generate the input sources
  # in a valid format.
  GET_DCONF_INPUT_SOURCES = home-manager: {
    "org/gnome/desktop/input-sources" = {
      "sources" =
        builtins.map
        (
          locale: home-manager.lib.hm.gvariant.mkTuple ["xkb" locale.gnome_input_name]
        )
        LOCALES;
      "xkb-options" = ["caps:escape" "grp:win_space_toggle"];
    };
  };

  DCONF_SETTINGS = {
    "org/gnome/settings-daemon/plugins/color" = {
      "night-light-enabled" = true;
    };
    "org/gnome/settings-daemon/plugins/color" = {
      "night-light-schedule-automatic" = false;
    };
    "org/gnome/settings-daemon/plugins/color" = {
      "night-light-schedule-from" = 0.0;
    };
    "org/gnome/settings-daemon/plugins/color" = {
      "night-light-schedule-to" = 0.0;
    };
    "org/gnome/settings-daemon/plugins/color" = {
      "night-light-temperature" = 2200;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      "natural-scroll" = false;
    };

    "org/gnome/desktop/interface" = {
      "show-battery-percentage" = true;
      "color-scheme" = "prefer-dark";
    };

    # This will disable prompts when plugging in a USB key
    "org/gnome/desktop/media-handling" = {
      "automount" = false;
      "automount-open" = false;
    };

    "org/gnome/shell" = {
      "favorite-apps" = [
        "org.gnome.Nautilus.desktop"
        "org.keepassxc.KeePassXC.desktop"
        "firefox.desktop"
        "thunderbird.desktop"
        "com.gitlab.newsflash.desktop"
        "org.gnome.Terminal.desktop"
      ];
    };

    # Gnome terminal options
    "org/gnome/terminal/legacy/keybindings" = {
      "default-show-menubar" = false;
    };
    "org/gnome/terminal/legacy/keybindings" = {
      "prev-tab" = "<Primary>h";
    };
    "org/gnome/terminal/legacy/keybindings" = {
      "next-tab" = "<Primary>l";
    };
    "org/gnome/terminal/legacy/keybindings" = {
      "new-tab" = "<Primary>t";
    };
    "org/gnome/terminal/legacy/keybindings" = {
      "full-screen" = "<Primary>f";
    };
    "org/gnome/terminal/legacy" = {
      "theme-variant" = "dark";
    };
    "org/gnome/terminal/legacy" = {
      "new-tab-position" = "next";
    };

    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      "use-system-font" = false;
    };
    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      "font" = "Monospace 14";
    };
    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      "audible-bell" = false;
    };
    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      "scrollback-unlimited" = true;
    };

    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      "palette" = [
        "rgb(0,0,0)"
        "rgb(170,0,0)"
        "rgb(0,170,0)"
        "rgb(170,85,0)"
        "rgb(181,162,250)"
        "rgb(170,0,170)"
        "rgb(0,170,170)"
        "rgb(206,105,105)"
        "rgb(201,109,109)"
        "rgb(255,85,85)"
        "rgb(85,255,85)"
        "rgb(255,255,85)"
        "rgb(85,85,255)"
        "rgb(255,85,255)"
        "rgb(85,255,255)"
        "rgb(185,78,78)"
      ];
    };
  };

  DEFAULT_USERNAME = "louib";
}
