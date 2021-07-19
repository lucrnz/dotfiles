call plug#begin()
Plug 'vim-airline/vim-airline'
Plug 'universal-ctags/ctags'
Plug 'preservim/tagbar'
Plug 'luochen1990/rainbow'
Plug 'vim-syntastic/syntastic'
Plug 'tpope/vim-surround'
Plug 'tommcdo/vim-lion'
Plug 'ntpeters/vim-better-whitespace'
Plug 'ctrlpvim/ctrlp.vim'

" Programming Languages
Plug 'sheerun/vim-polyglot'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'OmniSharp/omnisharp-vim'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" Themes
Plug 'drewtempelmeyer/palenight.vim'
call plug#end()

set runtimepath+=~/.config/nvim/syntax

syntax on
set nocompatible
set number relativenumber
set ruler
set colorcolumn=80
set visualbell
set encoding=utf-8
set wrap
set laststatus=2
set hlsearch
set incsearch
set autoindent
set smartindent
set nobackup
set nowritebackup
set noscrollbind
set updatetime=300
set signcolumn=yes
set autochdir
set mouse=a
set clipboard+=unnamedplus

nnoremap <c-z> <nop>
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

function! SetTab(n)
    let &l:tabstop=a:n
    let &l:softtabstop=a:n
    let &l:shiftwidth=a:n
    set expandtab
endfunction

command! -nargs=1 SetTab call SetTab(<f-args>)

function! Trim()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
command! -nargs=0 Trim call Trim()

" netrw - File browser
nnoremap - :Explore<CR>
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'
autocmd FileType netrw setl bufhidden=delete

" ctrlp affects git ignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" Theme
colorscheme palenight
let g:rainbow_active = 1
