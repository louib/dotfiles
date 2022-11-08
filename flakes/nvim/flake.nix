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
          languageServers = with pkgs; [
            rust-analyzer
            rustfmt
            stylua
            alejandra
            shellcheck
            # This one is for clangd, the LSP for C and C++, and for clang-format
            clang-tools
          ];
        in {
          packages = {
            # TODO export the language servers
            neovim-louib = pkgs.neovim.override {
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
                # customRC = "";
                # TODO plug in the LUA config.
              };
            };
          };
        }
      )
    )
  );
}
