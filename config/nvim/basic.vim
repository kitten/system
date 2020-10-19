" Set default shell
set shell=/bin/bash

set hidden

" Encoding
set encoding=utf8

" Mouse stuff
set mouse+=a

" Indentation
filetype plugin indent off
set autoindent
set nosmartindent
set ts=2
set shiftwidth=2
set expandtab

" Max Width
set textwidth=0

" Lazy redraw for e.g. macros
set lazyredraw

" Lower default updatetime
set updatetime=500

" No wrapping
set nowrap

" Make backspace usable
set backspace=indent,eol,start

" Show matching brackets
set showmatch

" Searching
set ignorecase
set hlsearch
set incsearch

" Smartcaps
set smartcase

" Statusbar
set ruler
set laststatus=2
set statusline=%F%m%r%h%w\ [%l,%c]\ [%L,%p%%]

" Scrolling
set scrolloff=2

" No Backup
set nobackup
set nowritebackup
set nowb
set noswapfile

set shortmess+=I
set shortmess+=c

" Line numbers
set number

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Always use vertical diffs
set diffopt+=vertical

" Italics support
set t_ZH=^[[3m
set t_ZR=^[[23m

" Fold by indentation
set foldenable
set foldmethod=indent
set foldnestmax=9
set foldlevelstart=3

" Persist undo history
if has('persistent_undo')
  if !isdirectory($HOME."/.cache/vim")
    call mkdir($HOME."/.cache/vim", "", 0770)
  endif

  if !isdirectory($HOME."/.cache/vim/undo")
    call mkdir($HOME."/.cache/vim/undo", "", 0770)
  endif

  set undodir=~/.cache/vim/undo
  set undofile
  set undolevels=1000
  set undoreload=10000
endif

" Strip Trailing Whitespace on Save
function! TrimWhiteSpace()
  %s/\s\+$//e
endfunction
autocmd BufWritePre * :call TrimWhiteSpace()

" Clear message line 3s after holding
function! s:empty_message(timer)
  if mode() ==# 'n'
    echon ''
  endif
endfunction
autocmd CursorHold * call timer_start(3000, funcref('s:empty_message'))

augroup JavaScriptFolds
  autocmd!
  autocmd FileType javascript setlocal foldmethod=expr
  autocmd FileType javascript setlocal foldexpr=nvim_treesitter#foldexpr()
  autocmd FileType jsx setlocal foldmethod=expr
  autocmd FileType jsx setlocal foldexpr=nvim_treesitter#foldexpr()
augroup END

augroup TypeScriptFolds
  autocmd!
  autocmd FileType typescript setlocal foldmethod=expr
  autocmd FileType typescript setlocal foldexpr=nvim_treesitter#foldexpr()
  autocmd FileType tsx setlocal foldmethod=expr
  autocmd FileType tsx setlocal foldexpr=nvim_treesitter#foldexpr()
augroup END

" Command livepreview for nvim
if has('nvim')
  set inccommand=nosplit
endif
