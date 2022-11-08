{
  description = "My neovim configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-compat,
  }: {
    packages.x86_64-linux.default = nixpkgs.neovim.override {
      # vimAlias = true;
      # viAlias = true;
      configure = {
        packages.myPlugins = with nixpkgs.x86_64-linux.pkgs.vimPlugins; {
          start = [vim-lastplace vim-nix];
          opt = [];
        };
        customRC = ''
          " your custom vimrc
          set nocompatible
          set backspace=indent,eol,start
          " ...
        '';
      };
    };
  };
}
