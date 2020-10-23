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

function! ResetTheme()
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
endfunction

call ResetTheme()

" Goyo Hooks
function! s:goyo_enter()
  silent !tmux set status off
  silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  lua vim.api.nvim_set_var("golden_size_off", 1)
  set scrolloff=10
  Limelight
endfunction

function! s:goyo_leave()
  silent !tmux set status on
  silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  lua vim.api.nvim_set_var("golden_size_off", 0)
  set scrolloff=2
  Limelight!
  call ResetTheme()
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
