#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_DIR")

if [ -d "$HOME/.config/nvim" ]; then
    echo "✔️ NeoVim is already configured."
else
    # Creating the required directories.
    mkdir ~/.config/nvim
    mkdir ~/.config/nvim/autoload
    mkdir ~/.config/nvim/bundle
    mkdir ~/.config/nvim/ftplugin

    # Creating the config directories.
    # The list of supported directories can be found here https://github.com/nanotee/nvim-lua-guide#runtime-files
    mkdir -p ~/.local/share/nvim/site/pack/languages/start
    mkdir -p ~/.local/share/nvim/site/pack/colorschemes/start
    mkdir -p ~/.local/share/nvim/site/pack/others/start

    # TODO have a look at telescope, replaces ctrl-p and fzf

    # TODO check out https://github.com/L3MON4D3/LuaSnip
    git clone --recursive https://github.com/neovim/nvim-lspconfig.git ~/.local/share/nvim/site/pack/others/start/nvim-lspconfig
    git clone --recursive https://github.com/hrsh7th/nvim-cmp.git ~/.local/share/nvim/site/pack/others/start/nvim-cmp
    git clone --recursive https://github.com/hrsh7th/cmp-nvim-lsp.git ~/.local/share/nvim/site/pack/others/start/cmp-nvim-lsp
    git clone --recursive https://github.com/hrsh7th/cmp-buffer.git ~/.local/share/nvim/site/pack/others/start/cmp-buffer
    # git clone --recursive https://github.com/hrsh7th/cmp-path.git ~/.local/share/nvim/site/pack/others/start/cmp-path
    # git clone --recursive https://github.com/hrsh7th/cmp-cmdline.git ~/.local/share/nvim/site/pack/others/start/cmp-cmdline
    git clone --recursive https://github.com/tpope/vim-surround.git ~/.local/share/nvim/site/pack/others/start/vim-surround
    git clone --recursive https://github.com/vim-airline/vim-airline ~/.local/share/nvim/site/pack/others/start/vim-airline
    git clone --recursive https://github.com/numToStr/Comment.nvim.git ~/.local/share/nvim/site/pack/others/start/Comment.nvim

    git clone --recursive https://github.com/leafgarland/typescript-vim.git ~/.local/share/nvim/site/pack/languages/start/typescript
    git clone --recursive https://github.com/rust-lang/rust.vim.git ~/.local/share/nvim/site/pack/languages/start/rust.vim

    git clone --recursive https://github.com/sainnhe/everforest.git ~/.local/share/nvim/site/pack/colorschemes/start/everforest
    git clone --recursive https://github.com/sainnhe/sonokai.git ~/.local/share/nvim/site/pack/colorschemes/start/sonokai

    # These should probably be migrated to proper LSP plugins
    # git clone --recursive https://github.com/pangloss/vim-javascript.git ~/.local/share/nvim/site/pack/languages/start/vim-javascript
    # git clone --recursive https://github.com/python-mode/python-mode.git ~/.local/share/nvim/site/pack/languages/start/python-mode
    # git clone --recursive https://github.com/hashivim/vim-terraform.git ~/.local/share/nvim/site/pack/languages/start/vim-terraform

    # Copying language files.
    cp "$SCRIPT_DIR/../assets/vim/javascript.vim" ~/.config/nvim/ftplugin/
    cp "$SCRIPT_DIR/../assets/vim/sh.vim" ~/.config/nvim/ftplugin/
    cp "$SCRIPT_DIR/../assets/vim/typescript.vim" ~/.config/nvim/ftplugin/
    cp "$SCRIPT_DIR/../assets/vim/cpp.vim" ~/.config/nvim/ftplugin/
    cp "$SCRIPT_DIR/../assets/vim/python.vim" ~/.config/nvim/ftplugin/
    echo "✔️ Configured NeoVim"
fi

if [[ ! -f "$HOME/.config/nvim/init.vim" ]]; then
    cp "$SCRIPT_DIR/../assets/vim/init.vim" ~/.config/nvim/
    echo "✔️ Configured vim init file."
elif [[ -n $(diff "$SCRIPT_DIR/../assets/vim/init.vim" "$HOME/.config/nvim/init.vim") ]]; then
    cp "$SCRIPT_DIR/../assets/vim/init.vim" ~/.config/nvim/
    echo "✔️ Updated vim init file."
else
    echo "✔️ vim init file already configured, skipping."
fi

# We don't place the init.lua file at the root of the config
# because nvim does not support both an init.vim and an init.lua.
# We could move it to the root once (if) the init.vim
# gets completely deprecated.
INIT_LUA_DESTINATION_DIR="$HOME/.config/nvim/lua"
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

if [[ ! -f "/home/${USER}/.var/app/io.neovim.nvim/config/nvim/init.vim" ]]; then
    echo "Linking nvim config to Flatpak sandbox."

    # If neovim was installed through flatpak, we need this alias
    mkdir -p "/home/${USER}/.var/app/io.neovim.nvim/config"
    ln -v -s "$HOME/.config/nvim" "/home/${USER}/.var/app/io.neovim.nvim/config"
    rm -r "/home/${USER}/.var/app/io.neovim.nvim/data"
    mkdir -p "/home/${USER}/.var/app/io.neovim.nvim/data"
    ln -v -s "$HOME/.local/share/nvim" "/home/${USER}/.var/app/io.neovim.nvim/data"
fi
