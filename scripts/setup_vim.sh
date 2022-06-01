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

    # Installing plugins.
    mkdir -p ~/.local/share/nvim/site/pack/languages/start
    mkdir -p ~/.local/share/nvim/site/pack/colorschemes/start
    mkdir -p ~/.local/share/nvim/site/pack/others/start

    # TODO have a look at https://github.com/tpope/vim-commentary or https://github.com/tomtom/tcomment_vim
    # for handling comments.

    # TODO have a look at https://github.com/dense-analysis/ale for language features.

    git clone --recursive https://github.com/leafgarland/typescript-vim.git ~/.local/share/nvim/site/pack/languages/start/typescript
    git clone --recursive https://github.com/octol/vim-cpp-enhanced-highlight.git ~/.local/share/nvim/site/pack/languages/start/vim-cpp-enhanced-highlight
    git clone --recursive https://github.com/rust-lang/rust.vim.git ~/.local/share/nvim/site/pack/languages/start/rust.vim
    git clone --recursive https://github.com/morhetz/gruvbox.git ~/.local/share/nvim/site/pack/colorschemes/start/gruvbox
    git clone --recursive https://github.com/tpope/vim-surround.git ~/.local/share/nvim/site/pack/others/start/vim-surround
    git clone --recursive https://github.com/vim-airline/vim-airline ~/.local/share/nvim/site/pack/others/start/vim-airline

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
    echo "✔️ Configured Vim init file."
elif [[ -n $(diff "$SCRIPT_DIR/../assets/vim/init.vim" "$HOME/.config/nvim/init.vim") ]]; then
    cp "$SCRIPT_DIR/../assets/vim/init.vim" ~/.config/nvim/
    echo "✔️ Updated Vim init file."
else
    echo "✔️ Vim init file already configured, skipping."
fi

# If neovim was installed through flatpak, we need this alias
# mkdir -p "/home/${USER}/.var/app/io.neovim.nvim/config"
# ln -v -s "$HOME/.config/nvim" "/home/${USER}/.var/app/io.neovim.nvim/config"
# rm -r "/home/${USER}/.var/app/io.neovim.nvim/data"
# mkdir -p "/home/${USER}/.var/app/io.neovim.nvim/data"
# ln -v -s "$HOME/.local/share/nvim" "/home/${USER}/.var/app/io.neovim.nvim/data"
