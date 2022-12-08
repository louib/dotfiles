{
  description = "Collection of functions that define my shell (bash/zsh) configuration";

  outputs = {self}: {
    lib = rec {
      # The top-level environment variables that should be defined in my shell.
      VARIABLES = {
        VISUAL = "nvim";
        EDITOR = "nvim";
      };
      SHELL_CONFIG = builtins.readFile (./. + "/shell-init.sh");
      BASH_CONFIG = (builtins.readFile (./. + "/bashrc.sh")) + SHELL_CONFIG;
      ZSH_CONFIG = (builtins.readFile (./. + "/zshrc.sh")) + SHELL_CONFIG;
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
