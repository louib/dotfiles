{
  description = "Static values in my Nix configuration";

  outputs = {self}: {
    lib = rec {
      # This list is derived from https://github.com/numtide/flake-utils/blob/5aed5285a952e0b949eb3ba02c12fa4fcfef535f/default.nix#L3
      # from which I removed the Darwin systems.
      defaultSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      defaultLocale = {
        name = "en_CA.UTF-8";
        ticker = "en";
      };

      locales = [
        defaultLocale
        {
          name = "fr_CA.UTF-8";
          ticker = "ca";
        }
      ];

      DCONF_SETTINGS = {
        "org/gnome/desktop/input-sources" = {
          "xkb-options" = ["caps:escape" "grp:win_space_toggle"];
        };

        "org/gnome/desktop/peripherals/touchpad" = {
          "natural-scroll" = false;
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
      };

      defaultUsername = "louib";
    };
  };
}
