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

  GNOME_TERMINAL_PROFILE_SETTINGS = {
    "use-system-font" = false;
    "font" = "Monospace 14";
    "audible-bell" = false;
    "scrollback-unlimited" = true;
    "palette" = [
      "rgb(0,0,0)"
      "rgb(170,0,0)"
      "rgb(0,170,0)"
      "rgb(240,167,94)"
      "rgb(114,79,241)"
      "rgb(170,0,170)"
      "rgb(0,170,170)"
      "rgb(206,105,105)"
      "rgb(201,109,109)"
      "rgb(194,27,27)"
      "rgb(85,255,85)"
      "rgb(200,200,136)"
      "rgb(85,85,255)"
      "rgb(224,55,224)"
      "rgb(60,226,226)"
      "rgb(185,78,78)"
    ];
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

    # This is the default Ubuntu profile UUID
    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = GNOME_TERMINAL_PROFILE_SETTINGS;
    # This is the default NixOS profile UUID
    "org/gnome/terminal/legacy/profiles:/:93324bd5-ae93-45b8-9af9-a7dbc5bfcd42" = GNOME_TERMINAL_PROFILE_SETTINGS;
  };

  DEFAULT_USERNAME = "louib";
}
