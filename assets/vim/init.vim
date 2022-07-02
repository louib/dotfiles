augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l* lwindow
augroup END

" Running spell checking by default on specific text files.
" See https://vimtricks.com/p/vimtrick-spell-checking-in-vim/ for
" the spell checking shortcuts.
autocmd FileType tex :setlocal spell
autocmd FileType markdown :setlocal spell

autocmd FileType sh :set tabstop=4
autocmd FileType sh :set shiftwidth=4
autocmd FileType cpp :set tabstop=4
autocmd FileType cpp :set shiftwidth=4
autocmd FileType python :set tabstop=4
autocmd FileType python :set shiftwidth=4

lua << EOF
  require('init').configure()
EOF
