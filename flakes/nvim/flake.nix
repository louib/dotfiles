{
  description = "My neovim configuration";

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
            inherit rnix-lsp;
            inherit rust-analyzer;
            inherit rustfmt;
            inherit stylua;
            inherit alejandra;
            inherit shellcheck;
            # This one is for clangd, the LSP for C and C++, and for clang-format
            inherit clang-tools;
            typescript-language-server = nodePackages.typescript-language-server;
          };
          # FIXME this is ugly and the lua config should be moved inside the flake.
          neovimLuaConfig = builtins.readFile (./. + "../../../assets/vim/init.lua");
          customNeovim = pkgs.neovim.override {
            # vimAlias = true;
            configure = {
              packages.myPlugins = with pkgs.vimPlugins; {
                start = [
                  vim-nix
                  vim-surround
                  lualine-nvim
                  comment-nvim
                  formatter-nvim
                  typescript-vim
                  rust-vim
                  nvim-lspconfig
                  nvim-cmp
                  cmp-nvim-lsp
                  cmp-buffer

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
