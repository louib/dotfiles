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
            inherit rnix-lsp;
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
            json-language-server = nodePackages.vscode-langservers-extracted;
            bash-language-server = nodePackages.bash-language-server;
          };
          neovimLuaConfig = builtins.readFile (./. + "/init.lua");
          customNeovim = pkgs.neovim.override {
            # vimAlias = true;
            configure = {
              packages.myPlugins = with pkgs.vimPlugins; {
                start = [
                  # TODO have a look at telescope, replaces ctrl-p and fzf
                  # TODO check out https://github.com/akinsho/toggleterm.nvim
                  # TODO check out https://github.com/zakharykaplan/nvim-retrail
                  git-blame-nvim
                  vim-surround
                  lualine-nvim
                  comment-nvim
                  formatter-nvim
                  nvim-lastplace
                  nvim-lspconfig
                  nvim-cmp
                  cmp-nvim-lsp
                  cmp-buffer
                  cmp-path
                  cmp-cmdline

                  # Language-related plugins
                  vim-nix
                  typescript-vim
                  rust-vim

                  # Colorschemes
                  everforest
                  sonokai
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
