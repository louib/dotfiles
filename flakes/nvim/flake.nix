{
  description = "My Neovim configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: (
    flake-utils.lib.eachDefaultSystem (
      system: (
        let
          pkgs = nixpkgs.legacyPackages.${system};
          languageTools = with pkgs; {
            inherit actionlint;
            # xclip (or wl-clipboard) is required to clip to the system clipboard.
            inherit xclip;
            # Copilot requires a version of Node.js > 16.x
            inherit nodejs_22;
            inherit nil;
            inherit rust-analyzer;
            inherit cargo;
            inherit rustc;
            inherit rustfmt;
            inherit stylua;
            inherit ruff;
            inherit alejandra;
            inherit shellcheck;
            # This one is for clangd, the LSP for C and C++, and for clang-format
            inherit clang-tools;
            # I believe this is the same package as sumneko-lua-language-server
            inherit lua-language-server;
            # Go language server and tools
            inherit gopls;
            inherit go;
            inherit gotools; # Includes goimports and other useful Go tools
            typescript-language-server = nodePackages.typescript-language-server;
            yaml-language-server = nodePackages.yaml-language-server;
            json-language-server = nodePackages.vscode-langservers-extracted;
            bash-language-server = nodePackages.bash-language-server;
            # There is also terraform-lsp which I could try
            inherit terraform-ls;
            inherit taplo;
            inherit dockerfile-language-server;

            inherit ripgrep;
            inherit wordnet;

            inherit markdownlint-cli;
          };

          # Load colors from TOML file
          colors = builtins.fromTOML (builtins.readFile (../.. + "/colorscheme/colors.toml"));

          # Create the environment variables for Neovim colors
          colorEnv =
            {
              # Enable custom colors
              "NVIM_COLOR_ENABLED" = "true";
            }
            // (pkgs.lib.mapAttrs' (name: value: {
                # Convert kebab-case or snake_case to UPPER_SNAKE_CASE with NVIM_COLOR_ prefix
                name = "NVIM_COLOR_" + (pkgs.lib.strings.toUpper (builtins.replaceStrings ["-" "_"] ["_" "_"] name));
                # Remove # from colors if present
                value =
                  if (builtins.isString value) && (builtins.substring 0 1 value == "#")
                  then builtins.substring 1 (builtins.stringLength value - 1) value
                  else value;
              })
              colors.nvim);

          neovimLuaConfig = builtins.readFile (./. + "/init.lua");
          customNeovim = pkgs.neovim.override {
            configure = {
              packages.myPlugins = with pkgs.vimPlugins; {
                start = [
                  git-blame-nvim
                  vim-surround
                  lualine-nvim

                  comment-nvim
                  nvim-comment

                  formatter-nvim
                  nvim-lastplace
                  nvim-cmp
                  cmp-emoji
                  cmp-nvim-lsp
                  cmp-buffer
                  cmp-path
                  cmp-cmdline
                  cmp-dictionary
                  cmp-spell

                  cmp-vsnip # required to add completion engine support to nvim-cmp
                  vim-vsnip # required to add completion engine support to nvim-cmp

                  copilot-lua
                  copilot-cmp

                  fzf-lua

                  # Language-related plugins
                  vim-nix
                  typescript-vim
                  rust-vim
                  vim-go
                ];
                opt = [];
              };

              # There's no way to provide the Lua config directly, but we can embed it in the
              # traditional Vim config file.
              customRC = ''
                lua <<EOF
                ${neovimLuaConfig}
                EOF
              '';
            };
          };

          # Create a new derivation with Neovim and the color environment variables
          neovimWithColors = pkgs.writeShellScriptBin "nvim" ''
            # Set color environment variables
            ${builtins.concatStringsSep "\n" (
              pkgs.lib.mapAttrsToList (name: value: "export ${name}=${value}") colorEnv
            )}

            # Execute original Neovim
            exec ${customNeovim}/bin/nvim "$@"
          '';
        in {
          packages = (
            {
              inherit neovimWithColors;
            }
            // languageTools
          );
        }
      )
    )
  );
}
