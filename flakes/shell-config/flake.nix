{
  description = "Collection of functions that define my shell (bash/zsh) configuration";

  outputs = {self}: {
    lib = rec {
      # The top-level environment variables that should be defined in my shell.
      VARIABLES = {
        VISUAL = "nvim";
        EDITOR = "nvim";
      };
      SHELL_CONFIG = builtins.readFile (./. "/shell-init.sh");
      BASH_CONFIG = (builtins.readFile (./. "/bashrc.sh")) + SHELL_CONFIG;
      ZSH_CONFIG = ''
        # Have a look at https://github.com/softmoth/zsh-vim-mode at some point, to get better
        # bindings for vim zsh.
        bindkey -v

        # Have a look at all the bindings at https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets
        bindkey ^R history-incremental-search-backward
        bindkey ^S history-incremental-search-forward

        if [ -x "$(command -v starship)" ]; then
            eval "$(starship init zsh)"
        fi
      '';
      # This is the extra configuration that can only be defined in an RC (like ~/.bashrc) file.

      STARSHIP_CONFIG = builtins.fromTOML (builtins.readFile (./. + "/starship.toml"));
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
