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

  GIT_COLORS_CONFIG = {
    colors = {
      ui = "auto";
      branch = {
        current = "136 bold"; # yellow bold
        local = "64"; # green
        remote = "160"; # red
      };
      diff = {
        meta = "33"; # bright blue
        frag = "61"; # soft violet
        old = "160"; # deep red
        new = "64"; # soft green
        whitespace = "160 reverse"; # deep red reverse
      };
      status = {
        added = "64"; # green
        changed = "136"; # yellow
        untracked = "160"; # red
      };
      decorate = {
        branch = "64 bold"; # green bold
        remoteBranch = "160 bold"; # red bold
        tag = "136 bold"; # yellow bold
        stash = "125"; # magenta
        HEAD = "33 bold"; # blue bold
      };
      interactive = {
        prompt = "33 bold"; # blue bold
        header = "160 bold"; # red bold
        help = "64 bold"; # green bold
        error = "160 bold"; # red bold
      };
    };
  };

  WEZTERM_CONFIG = builtins.readFile (./. + "/.wezterm.lua");
  AIDER_CONFIG = builtins.readFile (./. + "/.aider.conf.yml");

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
    "org/gnome/shell/extensions/dash-to-dock" = {
      "dock-fixed" = false;
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
        "org.wezfurlong.wezterm.desktop"
        "com.mitchellh.ghostty.desktop"
        "firefox.desktop"
        "thunderbird.desktop"
        "org.keepassxc.KeePassXC.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    # Gnome window mgmt options
    "org/gnome/desktop/wm/keybindings" = {
      "switch-to-workspace-left" = "<Shift><Control>h";
      "switch-to-workspace-right" = "<Shift><Control>l";
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
    # This is disabled because the default binding (<Primary>p) interferes
    # with neovim bindings.
    "org/gnome/terminal/legacy/keybindings" = {
      "find-previous" = "disabled";
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

  # See https://github.com/junegunn/fzf/wiki/Color-schemes#base-scheme for
  # the configuration of the base schemes.
  FZF_COLOR_SCHEME = "16";

  FZF_COLOR_CODES = {
    base03 = "234";
    base02 = "235";
    base01 = "240";
    base00 = "241";
    base0 = "244";
    base1 = "245";
    base2 = "254";
    base3 = "230";
    yellow = "136";
    orange = "166";
    red = "160";
    magenta = "125";
    violet = "61";
    blue = "33";
    cyan = "37";
    green = "64";
  };

  # See https://github.com/junegunn/fzf/wiki/Color-schemes#color-configuration
  # for all the color configurations
  # There's a color picker here https://minsw.github.io/fzf-color-picker/
  FZF_COLORS = {
    # highlighted substring
    "hl" = FZF_COLOR_CODES.magenta;
    # highlighted substring (current line)
    "hl+" = FZF_COLOR_CODES.red;
    # Background (current line)
    "bg+" = FZF_COLOR_CODES.violet;
    # gutter on the left
    "gutter" = FZF_COLOR_CODES.blue;
    "fg+" = FZF_COLOR_CODES.base2;
    "info" = FZF_COLOR_CODES.cyan;
    "prompt" = FZF_COLOR_CODES.cyan;
    "spinner" = "108";
    "pointer" = FZF_COLOR_CODES.violet;
    # "marker" = FZF_COLOR_CODES.base02;
    "marker" = FZF_COLOR_CODES.yellow;
    "header" = FZF_COLOR_CODES.cyan;
    "border" = FZF_COLOR_CODES.yellow;
  };

  GET_FZF_COLORS_FLATTENED = nixpkgs:
    builtins.concatStringsSep ","
    (nixpkgs.lib.mapAttrsToList (name: value: "${name}:${value}") FZF_COLORS);

  GET_FZF_DEFAULT_OPTIONS = nixpkgs: "export FZF_DEFAULT_OPTS=\"$FZF_DEFAULT_OPTS --color ${FZF_COLOR_SCHEME},${GET_FZF_COLORS_FLATTENED nixpkgs}\"";
}
