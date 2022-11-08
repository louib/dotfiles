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
        in {
          packages = {
            neovim-louib = pkgs.neovim.override {
              # vimAlias = true;
              configure = {
                packages.myPlugins = with pkgs.vimPlugins; {
                  start = [
                    vim-nix
                    nvim-lspconfig
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
