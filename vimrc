set nocompatible
set shortmess=atI

" No beep
set noerrorbells
set novisualbell
set t_vb=

" GUI
set number
set scrolloff=3
set laststatus=2
set lazyredraw

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
