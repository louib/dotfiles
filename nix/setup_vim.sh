#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

nix-env -iA nixpkgs.neovim

nix-env -iA nixpkgs.vimPlugins.nvim-lspconfig
nix-env -iA nixpkgs.vimPlugins.vim-surround
nix-env -iA nixpkgs.vimPlugins.nvim-cmp
nix-env -iA nixpkgs.vimPlugins.lualine-nvim
nix-env -iA nixpkgs.vimPlugins.cmp-nvim-lsp
nix-env -iA nixpkgs.vimPlugins.cmp-buffer
nix-env -iA nixpkgs.vimPlugins.formatter-nvim
# FIXME I did not find https://github.com/numToStr/Comment.nvim.git in nixpkgs

# Colorschemes
nix-env -iA nixpkgs.vimPlugins.sonokai
nix-env -iA nixpkgs.vimPlugins.everforest

# TODO I still need the following plugins?
# https://github.com/leafgarland/typescript-vim.git
# https://github.com/rust-lang/rust.vim.git

# TODO check out https://github.com/nvim-telescope/telescope.nvim.git
# TODO check out https://github.com/akinsho/toggleterm.nvim
# TODO check out https://github.com/akinsho/bufferline.nvim
# TODO check out https://github.com/ethanholz/nvim-lastplace to replace the snippet I had to return to the last edited line.
# TODO check out https://github.com/kyazdani42/nvim-web-devicons.git
# TODO check out https://github.com/L3MON4D3/LuaSnip
# TODO check out https://github.com/lewis6991/gitsigns.nvim.git
# TODO check out https://github.com/hrsh7th/cmp-path.git
# TODO check out https://github.com/hrsh7th/cmp-cmdline.git
