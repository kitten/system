" Filetype for prisma
au BufRead,BufNewFile *.prisma setfiletype graphql

" Completion
autocmd BufEnter * lua require'completion'.on_attach()
let g:completion_trigger_keyword_length = 3
let g:completion_timer_cycle = 100
set completeopt=menuone,noinsert,noselect
set shortmess+=c

" Diagnostic
let g:diagnostic_enable_virtual_text = 1
let g:diagnostic_virtual_text_prefix = '←'
let g:diagnostic_insert_delay = 1
call sign_define("LspDiagnosticsErrorSign", {"text" : "●", "texthl" : "LspDiagnosticsError"})
call sign_define("LspDiagnosticsWarningSign", {"text" : "◐", "texthl" : "LspDiagnosticsWarning"})

" Polyglot
let g:javascript_plugin_flow = 1
let g:jsx_ext_required = 0

" EasyMotion
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1
let g:EasyMotion_startofline = 0

" Fugitive
let g:Gitv_OpenHorizontal = 1
let g:Gitv_WipeAllOnClose = 1
let g:Gitv_DoNotMapCtrlKey = 1

" fzf
let g:fzf_layout = { 'down': '~30%' }
let g:fzf_buffers_jump = 1

" Vitality
let g:vitality_always_assume_iterm = 1

" Limelight
let g:limelight_conceal_ctermfg = '#4c5259'
let g:limelight_conceal_guifg = '#4c5259'

" Goyo
let g:goyo_height = '85%'
let g:goyo_width = '80%'

" Lightline
set noshowmode

let g:lightline = {
  \ 'colorscheme': 'one',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'readonly', 'filename' ] ],
  \ },
  \ 'component_function': {
  \   'filename': 'LightlineFilename',
  \ },
  \ }

function! LightlineFilename()
  let filename = @% !=# '' ? @% : 'Unnamed'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction
