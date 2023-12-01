""""""""""""""""""""""""""""""""""""""""""""""""""""
" Creator: hbin - huangbin88@foxmail.com
""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
set shortmess=atI

" No beep
set noerrorbells
set novisualbell
set t_vb=
autocmd! GUIEnter * set vb t_vb=

" GUI
set go=
set number
set scrolloff=3
set laststatus=2
set lazyredraw
set guioptions=e

if has("gui_running")
  if has("gui_gtk3")
    set guifont=Monaco\ 14
  elseif has("gui_win32")
    set guifont=Monaco:h14:cANSI
  else
    set guifont=Monaco:h16
  endif
endif

" Syntax highlight
syntax enable

" Formats & encoding
set encoding=utf-8
set fileencodings=utf-8
set fileformats=unix,dos,mac

" No temp files
set nobackup
set nowritebackup
set noswapfile

" Edit
set autoread
set backspace=start,indent,eol
set bsdir=buffer
set history=1024
set hidden
set list
set listchars=tab:,.,trail:.,extends:#,nbsp:.

" Tab
set expandtab
set smarttab
set tabstop=4
set shiftwidth=2

" Indentaion
set autoindent
set copyindent

" Word wrap
set nowrap
set iskeyword+=_,$,@,%,#,-

" Indentation
filetype plugin indent on

" Search
set ignorecase
set incsearch
set hlsearch

" Parenthensis
set showmatch
set matchtime=0

" Tab completion
set wildmenu
set wildmode=list:full

" Other
set viminfo=
set clipboard=unnamed

""""""""""""""""""""""""""""""
" =>>> Keys
""""""""""""""""""""""""""""""
let mapleader = " "

nmap Y y$

imap jj <ESC>
imap <C-b> <ESC>i
imap <C-f> <ESC>la

""""""""""""""""""""""""""""""
" =>>> Setting for Plugins
""""""""""""""""""""""""""""""

" CtrlP
let g:ctrlp_max_height=500

" NERDTree
nmap <leader>s :NERDTreeFind<CR>
nmap <leader>f :NERDTree<CR>

" Resolve key mapping conflict
nnoremap <leader>cr <Plug>RooterChangeToRootDirectory

" Ctags
set tags=tags
set tags+=../tags
set autochdir
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>

" python-mode
" let g:pymode_options_max_line_length = 0
let g:pymode_warnings = 0
let g:pymode_options_colorcolumn = 0
