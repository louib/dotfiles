{
  description = "Collection of functions that define my shell (bash/fish) configuration";

  outputs = {self}: {
    lib = rec {
      # The top-level environment variables that should be defined in my shell.
      VARIABLES = {
        VISUAL = "nvim";
        EDITOR = "nvim";
      };
      # This is the extra configuration that can only be defined in an RC (like ~/.bashrc) file.
      RC_CONFIG = ''
        # If not running interactively, don't do anything
        case $- in
            *i*) ;;
              *) return;;
        esac

        set -o vi

        # don't put duplicate lines or lines starting with space in the history.
        # See bash(1) for more options
        HISTCONTROL=ignoreboth

        # append to the history file, don't overwrite it
        shopt -s histappend

        # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
        HISTSIZE=1000
        HISTFILESIZE=2000
      '';
      SHELL_ALIASES = [
        # Defaults from template .bashrc config
        {
          name = "ll";
          target = "ls -alF";
        }
        {
          name = "la";
          target = "ls -A";
        }
        # Cargo stuff
        {
          name = "ci";
          target = "cargo install --force --path .";
        }
        {
          name = "cb";
          target = "cargo build";
        }
        {
          name = "ct";
          target = "cargo test";
        }
        {
          name = "cf";
          target = "find . -name '*.rs' -exec rustfmt {} \;";
        }
        # Nix stuff
        {
          name = "nix-search";
          target = "nix-env -qa";
        }
        {
          name = "ndv";
          target = "nix develop .";
        }
        {
          name = "nfc";
          target = "nix flake check";
        }
      ];
      SHELL_ALIASES_TUPLES = builtins.map (alias: [alias.name alias.target]) SHELL_ALIASES;
      SHELL_ALIASES_STRING = builtins.map (alias: "alias ${alias.name}=${alias.target}") SHELL_ALIASES;
    };
  };
}
