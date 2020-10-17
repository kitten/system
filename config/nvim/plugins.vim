" Filetype for prisma
au BufRead,BufNewFile *.prisma setfiletype graphql

" Completion
autocmd BufEnter * lua require'completion'.on_attach()
let g:completion_trigger_keyword_length = 3
let g:completion_timer_cycle = 100
set completeopt=menuone,noinsert,noselect
set shortmess+=c

" Configure the completion chains
let g:completion_chain_complete_list = {
  \'default' : {
  \	 'default' : [
  \		 {'complete_items' : ['lsp', 'buffer']},
  \		 {'mode' : 'file'}
  \	 ],
  \	 'comment' : [],
  \	 'string' : []
  \},
  \'json' : [{'complete_items': ['ts']}],
  \'javascript' : [{'complete_items': ['lsp']}],
  \'typescript' : [{'complete_items': ['lsp']}],
  \'jsx' : [{'complete_items': ['lsp']}],
  \'tsx' : [{'complete_items': ['lsp']}]
\}

" Diagnostic
let g:diagnostic_enable_virtual_text = 1
let g:diagnostic_virtual_text_prefix = '←'
let g:diagnostic_insert_delay = 1
call sign_define("LspDiagnosticsErrorSign", {"text" : "●", "texthl" : "LspDiagnosticsError"})
call sign_define("LspDiagnosticsWarningSign", {"text" : "◐", "texthl" : "LspDiagnosticsWarning"})

" LSP
autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()

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
