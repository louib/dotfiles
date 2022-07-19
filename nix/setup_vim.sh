#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

nix-env -iA nixpkgs.neovim

nix-env -iA nixpkgs.vimPlugins.nvim-lspconfig
nix-env -iA nixpkgs.vimPlugins.vim-surround
nix-env -iA nixpkgs.vimPlugins.nvim-cmp

# TODO check out https://github.com/nvim-telescope/telescope.nvim.git
# TODO check out https://github.com/akinsho/toggleterm.nvim
# TODO check out https://github.com/akinsho/bufferline.nvim
# TODO check out https://github.com/ethanholz/nvim-lastplace to replace the snippet I had to return to the last edited line.
# TODO check out https://github.com/kyazdani42/nvim-web-devicons.git
# TODO check out https://github.com/L3MON4D3/LuaSnip
# TODO check out https://github.com/lewis6991/gitsigns.nvim.git
# TODO check out https://github.com/hrsh7th/cmp-path.git
# TODO check out https://github.com/hrsh7th/cmp-cmdline.git
