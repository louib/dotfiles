" Enable filetypes
filetype plugin on
filetype plugin indent on

" Using the 'q' buffer as the quick buffer,
" with easy re-apply!
" Start recording that buffer with `qq`. Stop recording with `q`. Apply with
" space+q !!!
nnoremap <Space>q @q

" This will copy the visual selection to the clipboard on Ctrl-C.
map <C-c> "+y

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

lua << EOF
  require('init').configure()
EOF
