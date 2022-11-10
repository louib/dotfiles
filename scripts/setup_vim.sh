#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

# nix profile install nixpkgs#neovim
# nix profile install nixpkgs#rnix-lsp
# nix profile install nixpkgs#rust-analyzer
# nix profile install nixpkgs#rustfmt
# nix profile install nixpkgs#stylua
# nix profile install nixpkgs#alejandra
# nix profile install nixpkgs#shellcheck
# This one is for clangd, the LSP for C and C++, and for clang-format
# nix profile install nixpkgs#clang-tools

if [ -d "$HOME/.config/nvim" ]; then
    echo "✔️ NeoVim is already configured."
else
    # Creating the required directories.
    mkdir ~/.config/nvim
    mkdir ~/.config/nvim/autoload
    mkdir ~/.config/nvim/bundle

    # Creating the config directories.
    # The list of supported directories can be found here https://github.com/nanotee/nvim-lua-guide#runtime-files
    mkdir -p ~/.local/share/nvim/site/pack/languages/start
    mkdir -p ~/.local/share/nvim/site/pack/colorschemes/start
    mkdir -p ~/.local/share/nvim/site/pack/others/start
    # TODO install plugins with Nix.
    # See https://nixos.wiki/wiki/Overlays#Overriding_a_package_inside_an_attribute_set

    # TODO have a look at telescope, replaces ctrl-p and fzf
    #
    # TODO check out https://github.com/akinsho/toggleterm.nvim
    # TODO check out https://github.com/ethanholz/nvim-lastplace to replace the snippet I had to return to the last edited line.
    # TODO check out https://github.com/kyazdani42/nvim-web-devicons.git
    # TODO check out https://github.com/L3MON4D3/LuaSnip
    # TODO check out https://github.com/zakharykaplan/nvim-retrail
    git clone --recursive https://github.com/neovim/nvim-lspconfig.git ~/.local/share/nvim/site/pack/others/start/nvim-lspconfig
    git clone --recursive https://github.com/hrsh7th/nvim-cmp.git ~/.local/share/nvim/site/pack/others/start/nvim-cmp
    git clone --recursive https://github.com/hrsh7th/cmp-nvim-lsp.git ~/.local/share/nvim/site/pack/others/start/cmp-nvim-lsp
    git clone --recursive https://github.com/hrsh7th/cmp-buffer.git ~/.local/share/nvim/site/pack/others/start/cmp-buffer
    # git clone --recursive https://github.com/hrsh7th/cmp-path.git ~/.local/share/nvim/site/pack/others/start/cmp-path
    # git clone --recursive https://github.com/hrsh7th/cmp-cmdline.git ~/.local/share/nvim/site/pack/others/start/cmp-cmdline
    git clone --recursive https://github.com/tpope/vim-surround.git ~/.local/share/nvim/site/pack/others/start/vim-surround
    git clone --recursive https://github.com/nvim-lualine/lualine.nvim.git ~/.local/share/nvim/site/pack/others/start/lualine.nvim

    git clone --recursive https://github.com/numToStr/Comment.nvim.git ~/.local/share/nvim/site/pack/others/start/Comment.nvim
    git clone --recursive https://github.com/mhartington/formatter.nvim.git ~/.local/share/nvim/site/pack/others/start/formatter.nvim

    git clone --recursive https://github.com/leafgarland/typescript-vim.git ~/.local/share/nvim/site/pack/languages/start/typescript
    git clone --recursive https://github.com/rust-lang/rust.vim.git ~/.local/share/nvim/site/pack/languages/start/rust.vim
    git clone --recursive https://github.com/LnL7/vim-nix.git ~/.local/share/nvim/site/pack/languages/start/vim-nix

    git clone --recursive https://github.com/sainnhe/everforest.git ~/.local/share/nvim/site/pack/colorschemes/start/everforest
    git clone --recursive https://github.com/sainnhe/sonokai.git ~/.local/share/nvim/site/pack/colorschemes/start/sonokai

    # These should probably be migrated to proper LSP plugins
    # git clone --recursive https://github.com/pangloss/vim-javascript.git ~/.local/share/nvim/site/pack/languages/start/vim-javascript
    # git clone --recursive https://github.com/python-mode/python-mode.git ~/.local/share/nvim/site/pack/languages/start/python-mode
    # git clone --recursive https://github.com/hashivim/vim-terraform.git ~/.local/share/nvim/site/pack/languages/start/vim-terraform

    echo "✔️ Configured NeoVim"
fi

INIT_LUA_DESTINATION_DIR="$HOME/.config/nvim"
INIT_LUA_DESTINATION_PATH="$INIT_LUA_DESTINATION_DIR/init.lua"
if [[ ! -f "$INIT_LUA_DESTINATION_PATH" ]]; then
    mkdir -p "$INIT_LUA_DESTINATION_DIR"
    cp "$SCRIPT_DIR/../assets/vim/init.lua" "$INIT_LUA_DESTINATION_DIR"
    echo "✔️ Configured nvim init.lua file."
elif [[ -n $(diff "$SCRIPT_DIR/../assets/vim/init.lua" "$INIT_LUA_DESTINATION_PATH") ]]; then
    cp "$SCRIPT_DIR/../assets/vim/init.lua" "$INIT_LUA_DESTINATION_DIR"
    echo "✔️ Updated nvim init.lua file."
else
    echo "✔️ nvim init.lua file already configured, skipping."
fi
