call plug#begin()
Plug 'vim-airline/vim-airline'
Plug 'universal-ctags/ctags'
Plug 'preservim/tagbar'
Plug 'luochen1990/rainbow'
Plug 'vim-syntastic/syntastic'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-surround'
Plug 'tommcdo/vim-lion'
Plug 'ntpeters/vim-better-whitespace'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'easymotion/vim-easymotion'

" Programming Languages
Plug 'sheerun/vim-polyglot'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'rust-lang/rust.vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'pappasam/coc-jedi', { 'do': 'yarn install --frozen-lockfile && yarn build', 'branch': 'main' }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'yaegassy/coc-astro', {'do': 'yarn install --frozen-lockfile'}

" Themes
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
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
colorscheme tokyonight
set background=dark
"colorscheme monokai
"colorscheme palenight
let g:rainbow_active = 1

let g:ale_linters = {
\ 'cs': ['OmniSharp']
\}

let g:airline#extensions#ale#enabled = 1

" Coc Extensions
let g:coc_global_extensions = [
\ 'coc-tsserver', 'coc-deno', 'coc-rust-analyzer'
\]

" Vim Easymotion config
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
