" Set leader to space
let mapleader=" "
nnoremap <Space> <nop>

" unmap F1 help
nmap <F1> <nop>
imap <F1> <nop>

" Map <C-w> , to vsp and . to sp
nnoremap <C-w>, :vsp<CR>
nnoremap <C-w>. :sp<CR>

" Map semicolon to colon
noremap ; :

" Quick/Location list Toggle
nnoremap <silent> <Leader>q <cmd>lua require('telescope.builtin').quickfix()<CR>
nnoremap <silent> <Leader>p <cmd>lua require('telescope.builtin').loclist()<CR>

" File Search
nnoremap <silent> <Leader>o <cmd>lua require('telescope.builtin').git_files()<CR>
nnoremap <silent> <Leader>f <cmd>lua require('telescope.builtin').live_grep()<CR>
nnoremap <silent> <Leader>n <cmd>lua require('telescope.builtin').lsp_workspace_symbols()<CR>

" Easymotion Shortcuts
map n <Plug>(easymotion-next)
map N <Plug>(easymotion-prev)

" Gif config
map / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

" unmap arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Remap Arrow keys
map <Up> <Plug>(easymotion-k)
map <Down> <Plug>(easymotion-j)
map <Left> <Plug>(easymotion-linebackward)
map <Right> <Plug>(easymotion-lineforward)

" Move to previous/next buffer
nnoremap <silent> <leader>h :bprevious<CR>
nnoremap <silent> <leader>l :bnext<CR>

" Go to last used buffer
nnoremap <leader>j <C-^>

" Close a buffer
nnoremap <silent> <leader>k :bp <BAR> bd #<CR>

" List buffers
nnoremap <silent> <leader>b <cmd>lua require'telescope.builtin'.buffers()<CR>

" Toggle zen mode
nnoremap <silent> <leader>z :Goyo<CR>

" Blackhole all x commands and make X behave like d
nnoremap X "_d
nnoremap XX "_dd
vnoremap X "_d
vnoremap x "_d
nnoremap x "_x

" Make the dot command work as expected in visual mode (via
" https://www.reddit.com/r/vim/comments/3y2mgt/do_you_have_any_minor_customizationsmappings_that/cya0x04)
vnoremap . :norm.<CR>

" Allows you to visually select a section and then hit @ to run a macro on all lines
" https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db#.3dcn9prw6
function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction
" Executes a macro for each line in visual selection
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

" Have the indent commands re-highlight the last visual selection to make
" multiple indentations easier
vnoremap > >gv
vnoremap < <gv

" Make Ctrl-c behave exactly like Escape (because it matters to completions)
inoremap <c-c> <ESC>
xnoremap <c-c> <ESC>

" Use tab for trigger completion with characters ahead and navigate.
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Remap keys for gotos
nmap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nmap <silent> gy <cmd>lua vim.lsp.buf.type_definition()<CR>
nmap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nmap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>

" Use K to show documentation in preview window
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>

" Bind - to directory explorer
nnoremap <silent> - :Defx `expand('%:p:h')` -search=`expand('%:p')`<CR>
" Defx Mappings
autocmd FileType defx call s:defx_settings()
function! s:defx_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> -
  \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> h
  \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> l
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> <CR>
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> K
  \ defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> N
  \ defx#do_action('new_file')
  nnoremap <silent><buffer><expr> r
  \ defx#do_action('rename')
  nnoremap <silent><buffer><expr> !
  \ defx#do_action('execute_command')
  nnoremap <silent><buffer><expr> q
  \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> <Space>
  \ defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> j
  \ line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k
  \ line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> cd
  \ defx#do_action('change_vim_cwd')
endfunction
