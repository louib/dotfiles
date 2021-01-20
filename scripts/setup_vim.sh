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

    # Installing vim pathogen.
    curl -LSso ~/.config/nvim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    # Cloning plugins.
    git clone --recursive https://github.com/morhetz/gruvbox.git ~/.config/nvim/bundle/gruvbox
    # git clone --recursive https://github.com/sjl/badwolf.git ~/.config/nvim/bundle/badwolf
    # git clone --recursive https://github.com/ghifarit53/tokyonight-vim.git ~/.config/nvim/bundle/tokyonight
    # git clone --recursive https://github.com/nanotech/jellybeans.vim ~/.config/nvim/bundle/jellybeans
    # git clone --recursive http://ethanschoonover.com/solarized ~/.config/nvim/bundle/solarized
    git clone --recursive https://github.com/leafgarland/typescript-vim.git ~/.config/nvim/bundle/typescript-vim
    git clone --recursive https://github.com/pangloss/vim-javascript.git ~/.config/nvim/bundle/vim-javascript
    git clone --recursive https://github.com/python-mode/python-mode.git ~/.config/nvim/bundle/python-mode
    git clone --recursive https://github.com/tpope/vim-surround.git ~/.config/nvim/bundle/vim-surround
    # git clone --recursive https://github.com/skywind3000/asyncrun.vim ~/.config/nvim/bundle/asyncrun
    git clone --recursive https://github.com/vim-airline/vim-airline ~/.config/nvim/bundle/vim-airline
    git clone --recursive https://github.com/octol/vim-cpp-enhanced-highlight.git ~/.config/nvim/bundle/vim-cpp-enhanced-highlight
    git clone --recursive https://github.com/hashivim/vim-terraform.git ~/.config/nvim/bundle/vim-terraform
    # git clone --recursive https://github.com/arrufat/vala.vim.git ~/.config/nvim/bundle/vala.vim
    git clone --recursive https://github.com/rust-lang/rust.vim.git ~/.config/nvim/bundle/rust.vim

    # Copying config file
    cp "$SCRIPT_DIR/../assets/vim/init.vim" ~/.config/nvim/

    # Copying language files.
    cp "$SCRIPT_DIR/../assets/vim/javascript.vim" ~/.config/nvim/ftplugin/
    cp "$SCRIPT_DIR/../assets/vim/sh.vim" ~/.config/nvim/ftplugin/
    cp "$SCRIPT_DIR/../assets/vim/typescript.vim" ~/.config/nvim/ftplugin/
    cp "$SCRIPT_DIR/../assets/vim/cpp.vim" ~/.config/nvim/ftplugin/
    cp "$SCRIPT_DIR/../assets/vim/python.vim" ~/.config/nvim/ftplugin/
    echo "✔️ Configured NeoVim"
fi
