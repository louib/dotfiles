" Enable filetypes
filetype plugin on
filetype plugin indent on

"Buffer navigation and management
nnoremap <Space>w :bdelete<Enter>
nnoremap <Space>h :bprevious<Enter>
nnoremap <Space>l :bnext<Enter>
nnoremap <Space>1 :bfirst<Enter>
nnoremap <Space>2 :e #2<Enter>
nnoremap <Space>3 :e #3<Enter>
nnoremap <Space>4 :e #4<Enter>
nnoremap <Space>5 :e #5<Enter>
nnoremap <Space>6 :e #6<Enter>
nnoremap <Space>7 :e #7<Enter>
nnoremap <Space>8 :e #8<Enter>
nnoremap <Space>9 :e #9<Enter>

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
