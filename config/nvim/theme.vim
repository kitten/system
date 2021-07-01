" Enable true color support
if (has("nvim"))
  " For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

if (has("termguicolors"))
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162
  set termguicolors
endif

" Enable cursor shape switching
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

" Don't reset background colour
let &t_ut=''

" Better display for messages
set cmdheight=2

" Always show signcolumns
set signcolumn=yes

" Syntax highlighting
syntax enable
set cursorline
set background=dark
colorscheme theme
