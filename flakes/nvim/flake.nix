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
            inherit nodejs_20;
            inherit nil;
            inherit rust-analyzer;
            inherit cargo;
            inherit rustc;
            inherit rustfmt;
            inherit stylua;
            inherit alejandra;
            inherit shellcheck;
            # This one is for clangd, the LSP for C and C++, and for clang-format
            inherit clang-tools;
            # I believe this is the same package as sumneko-lua-language-server
            inherit lua-language-server;
            typescript-language-server = nodePackages.typescript-language-server;
            yaml-language-server = nodePackages.yaml-language-server;
            docker-language-server = nodePackages.dockerfile-language-server-nodejs;
            json-language-server = nodePackages.vscode-langservers-extracted;
            bash-language-server = nodePackages.bash-language-server;
            # There is also terraform-lsp which I could try
            inherit terraform-ls;
            inherit taplo-lsp;

            inherit ripgrep;
            inherit wordnet;

            inherit markdownlint-cli;
          };

          neovimLuaConfig = builtins.readFile (./. + "/init.lua");
          customNeovim = pkgs.neovim.override {
            # vimAlias = true;
            configure = {
              packages.myPlugins = with pkgs.vimPlugins; {
                start = [
                  # TODO check out https://github.com/akinsho/toggleterm.nvim
                  # TODO check out https://github.com/direnv/direnv.vim
                  git-blame-nvim
                  vim-surround
                  lualine-nvim

                  comment-nvim
                  nvim-comment

                  formatter-nvim
                  nvim-lastplace
                  nvim-lspconfig
                  nvim-cmp
                  cmp-emoji
                  cmp-nvim-lsp
                  cmp-buffer
                  cmp-path
                  cmp-cmdline
                  cmp-dictionary

                  # Required by copilotchat-nvim, cmp-dictionary, and potentially other plugins.
                  plenary-nvim

                  # both cmp-vsnip and vim-vsnip are required to add completion engine support
                  # to nvim-cmp
                  cmp-vsnip
                  vim-vsnip

                  copilot-lua
                  copilot-cmp
                  CopilotChat-nvim

                  fzf-lua

                  # Language-related plugins
                  vim-nix
                  typescript-vim
                  rust-vim

                  # Colorschemes
                  sonokai
                  vim-noctu
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
        in {
          packages = (
            {
              inherit customNeovim;
            }
            // languageTools
          );
        }
      )
    )
  );
}
