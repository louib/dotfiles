packloadall

set encoding=utf8
set pastetoggle=<F5>
set number
set relativenumber
syntax on

" Defaults for all file types.
set tabstop=2
set shiftwidth=2
set expandtab

" Make searching case insensitive
set ignorecase
" ... unless the query has capital letters.
set smartcase

set cursorline

" Disabling mainly for security reasons
set nomodeline

" Enable filetypes
filetype plugin on
filetype plugin indent on

set omnifunc=syntaxcomplete#Complete

" Always show the status line
set laststatus=2

" This will render the trailing spaces and the tabs in a visible way.
set listchars=tab:>-,trail:·
set list

" This is for intelligent merging of lines. Will handle comments for example.
if v:version > 703 || v:version == 703 && has('patch541')
  set formatoptions+=j
endif

" This beauty remembers where you were the last time you edited the file, and returns to the same position.
" I dont remember where I took this one from :(
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" WIP opens the first file in the current project that matches the search
" term.
function! LuckyOpen(term)
    let filename = system('find ./ | grep '.a:term.' | head -1')
    silent! execute "e ".filename
endfunction

"Window navigation and creation
nnoremap <Space>s <C-w>s
nnoremap <Space>v <C-w>v
nnoremap <Space>c <C-w>c
nnoremap <Space>j <C-w>j
nnoremap <Space>k <C-w>k

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
:nnoremap <Space>q @q

" This unsets the "last search pattern" register by hitting return
" Credits to https://stackoverflow.com/a/662914
nnoremap <CR> :noh<CR><CR>

" This will copy the visual selection to the clipboard on Ctrl-C.
map <C-c> "+y

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'

" Do not fold any of the block dy default.
set foldlevel=99

colorscheme gruvbox

set background=dark
set termguicolors

" the grep related configuration is inspired by
" https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
set grepprg=rg\ --vimgrep
set grepformat=%f:%l:%c:%m
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

" Settings for vim-cpp-enhanced-highlight
" See https://github.com/octol/vim-cpp-enhanced-highlight for details.
let g:cpp_no_function_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_class_scope_highlight = 1
let g:cpp_concepts_highlight = 1

lua << EOF
  -- See https://github.com/neovim/nvim-lspconfig#suggested-configuration for
  -- the suggested configuration.

  require'lspconfig'.rust_analyzer.setup{}
  -- require'lspconfig'.tsserver.setup{}
  -- TODO add eslint support?
  -- add vanilla JS support?
  -- add dockerfile support?
  -- add python support
  -- add C and C++ support
  -- add bash support (apparently there's a bash language server)
  -- require'lspconfig'.bashls.setup{}
  -- add YAML language server support?
  -- https://github.com/redhat-developer/yaml-language-server

  local custom_lsp_attach = function(client)
    -- Use LSP as the handler for omnifunc.
    --    See `:help omnifunc` and `:help ins-completion` for more information.
    vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Use LSP as the handler for formatexpr.
    --    See `:help formatexpr` for more information.
    vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
  end

EOF
