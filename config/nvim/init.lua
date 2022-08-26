-- utilities
local function t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function hi(group, str)
  return str ~= '' and string.format('%%#%s#%s', group, str) or ''
end

-- terminal options
vim.api.nvim_exec([[
  set t_ZH=^\[\[3m
  set t_ZR=^\[\[23m
  let &t_ut=''
]], false)

-- default save options
vim.o.hidden = true
vim.o.encoding = 'utf8'

-- scroll and mouse options
vim.o.mouse = vim.o.mouse .. 'a'
vim.o.scrolloff = 2

-- indentation options
vim.o.autoindent = true
vim.o.smartindent = false
vim.o.breakindent = true

-- default tab options
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- tweak redraw timings
vim.o.lazyredraw = true
vim.o.updatetime = 500
vim.o.timeoutlen = 500

-- show matching brackets
vim.o.showmatch = true

-- fold options
vim.o.foldenable = true
vim.o.foldmethod = 'indent'
vim.o.foldnestmax = 9
vim.o.foldlevelstart = 3

-- search options
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.inccommand = 'nosplit'

-- status options
vim.o.laststatus = 2
vim.o.statusline = '%F%m%r%h%w [%l,%c] [%L,%p%%]'

-- disable backups and swaps
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- no completion or startup messages
vim.o.shortmess = vim.o.shortmess .. 'cI'

-- line numbers
vim.wo.number = true

-- splitting options
vim.go.diffopt = 'filler,vertical,foldcolumn:0,closeoff,indent-heuristic,iwhite,algorithm:patience'
vim.go.fillchars = 'vert:│,diff:╱'
vim.go.splitbelow = true
vim.go.splitright = true

-- undo history
local undodir = vim.fn.expand('$HOME') .. '/.cache/nvim/undo'
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, 'p')
end

vim.o.undodir = undodir
vim.o.undofile = true
vim.o.undolevels = 1000
vim.o.undoreload = 10000

-- display options
vim.o.wrap = false
vim.o.showmode = false
vim.o.termguicolors = true
vim.o.cmdheight = 1
vim.o.background = 'dark'
vim.wo.signcolumn = 'number'
vim.wo.cursorline = true
vim.cmd('colorscheme theme')

-- misc. options
vim.o.completeopt = 'menuone,noinsert,noselect'
vim.o.pumheight = 10
vim.o.backspace = 'indent,eol,start'

-- polyglot
vim.g.javascript_plugin_flow = 1
vim.g.jsx_ext_required = 0
vim.g.vim_markdown_fenced_languages = { 'jsx=javascript', 'js=javascript', 'ts=typescript', 'bash=sh' }
vim.g.vim_markdown_json_frontmatter = 1

-- unmap special keys
local key_opt = { noremap = true, silent = true }
vim.api.nvim_set_keymap('', '<Space>', '<nop>', key_opt)
vim.api.nvim_set_keymap('', '<F1>', '<nop>', key_opt)
vim.api.nvim_set_keymap('i', '<F1>', '<nop>', key_opt)
vim.api.nvim_set_keymap('n', '<Up>', '<nop>', key_opt)
vim.api.nvim_set_keymap('n', '<Down>', '<nop>', key_opt)
vim.api.nvim_set_keymap('n', '<Left>', '<nop>', key_opt)
vim.api.nvim_set_keymap('n', '<Right>', '<nop>', key_opt)

-- period command in visual mode
vim.api.nvim_set_keymap('x', '.', ':norm.<CR>', key_opt)

-- match ctrl-c to escape
vim.api.nvim_set_keymap('', '<c-c>', '<ESC>', key_opt)
vim.api.nvim_set_keymap('!', '<c-c>', '<ESC>', key_opt)

-- window controls
vim.api.nvim_set_keymap('', '<c-w>,', ':vsp<CR>', key_opt)
vim.api.nvim_set_keymap('', '<c-w>.', ':sp<CR>', key_opt)

-- remap semicolon to colon
vim.api.nvim_set_keymap('n', ';', ':', { noremap = true })

-- destructive x-commands
vim.api.nvim_set_keymap('', 'X', '"_d', key_opt)
vim.api.nvim_set_keymap('n', 'XX', '"_dd', key_opt)
vim.api.nvim_set_keymap('v', 'x', '"_d', key_opt)
vim.api.nvim_set_keymap('n', 'x', 'v"_d', key_opt)

-- clipboard controls
vim.api.nvim_set_keymap('x', 'Y', '"+y', key_opt)
vim.api.nvim_set_keymap('x', '<M-c>', '"+y', key_opt)
vim.api.nvim_set_keymap('x', '<M-v>', '"+p', key_opt)
vim.api.nvim_set_keymap('n', '<M-v>', '"+P', key_opt)

-- indentation in visual mode
vim.api.nvim_set_keymap('v', '<', '<gv', key_opt)
vim.api.nvim_set_keymap('v', '>', '>gv', key_opt)

-- macros per line
vim.api.nvim_set_keymap('v', '@', ':<C-u>execute ":\'<,\'>normal @".nr2char(getchar())<CR>', key_opt)

-- set space as leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- which-key
local key = require('which-key')

key.setup {
  icons = {
    breadcrumb = " ",
    separator = "→",
    group = "+",
  },
  popup_mappings = {
    scroll_down = '<c-f>',
    scroll_up = '<c-d>',
  },
}

key.register({
  -- buffer shortcuts
  ["<leader>h"] = { "<cmd>bp<cr>", "Previous Buffer" },
  ["<leader>l"] = { "<cmd>bn<cr>", "Next Buffer" },
  ["<leader>j"] = { "<cmd>enew<cr>", "New Buffer" },
  ["<leader>j"] = { "<cmd>bp <bar> bd #<cr>", "Close Buffer" },
  -- fold controls
  ["<bar>"] = { "<cmd><c-u>normal zc<cr>", "Close Fold" },
  ["<bslash>"] = { "<cmd><c-u>normal za<cr>", "Open Fold" },
  -- lir
  ["-"] = { "<cmd>e %:p:h<cr>", "Open File Explorer" },
})

-- golden_size
local function ignore_trouble_window()
  if vim.api.nvim_buf_get_option(0, 'filetype') == 'Trouble' then
    return 1
  end
end

require('golden_size').set_ignore_callbacks {
  { ignore_trouble_window },
  { require('golden_size').ignore_float_windows },
  { require('golden_size').ignore_by_window_flag },
}

-- hop
require('hop').setup({ teasing = false })

vim.api.nvim_set_keymap('', '<Up>', "<cmd>lua require('hop').hint_lines_skip_whitespace({ direction = 1 })<CR>", key_opt)
vim.api.nvim_set_keymap('', '<Down>', "<cmd>lua require('hop').hint_lines_skip_whitespace({ direction = 2 })<CR>", key_opt)
vim.api.nvim_set_keymap('', '<Left>', "<cmd>lua require('hop').hint_words({ direction = 1 })<CR>", key_opt)
vim.api.nvim_set_keymap('', '<Right>', "<cmd>lua require('hop').hint_words({ direction = 2 })<CR>", key_opt)

-- telescope
require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      nix_bins.ripgrep,
      '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case'
    },
    prompt_prefix = ' ',
    selection_caret = '→ ',
    mappings = {
      i = {
        ['<c-t>'] = require('trouble.providers.telescope').open_with_trouble,
        ['<c-c>'] = require('telescope.actions').close,
      },
      n = {
        ['<c-t>'] = require('trouble.providers.telescope').open_with_trouble,
        ['<esc>'] = require('telescope.actions').close,
      },
    },
  },
}

-- global leader keybindings
local telescope_builtins = require('telescope.builtin')
key.register({
  ["<leader>q"] = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix List" },
  ["<leader>p"] = { "<cmd>TroubleToggle loclist<cr>", "Location List" },
  ["<leader>d"] = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document Diagnostics" },
  ["<leader>D"] = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics" },
  ["<leader>o"] = { telescope_builtins.git_files, "Search Files in Git" },
  ["<leader>f"] = { telescope_builtins.live_grep, "Search in Files" },
  ["<leader>n"] = { telescope_builtins.lsp_dynamic_workspace_symbols, "Search Symbols in LSP Workspace" },
  ["<leader>b"] = { telescope_builtins.buffers, "Search for Buffer" },
})

-- define signs
vim.fn.sign_define("DiagnosticSignError", { text = "●", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "◐", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "○", texthl = "DiagnosticSignInformation" })

-- configure vim diagnostics
vim.diagnostic.config({
  underline = true,
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    show_header = true,
    source = "if_many",
    border = "rounded",
    focusable = false,
    severity_sort = true,
  },
})

-- customise hover window size
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  max_width = math.max(math.floor(vim.o.columns * 0.7), 100),
  max_height = math.max(math.floor(vim.o.lines * 0.3), 30),
})

-- lspconfig
local lsp = require('lspconfig')

local function lsp_on_attach(client, buf)
  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end

  vim.api.nvim_buf_set_option(buf, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
  vim.api.nvim_buf_set_option(buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_buf_set_option(buf, 'tagfunc', 'v:lua.vim.lsp.tagfunc')

  if pcall(function()
    return vim.api.nvim_buf_get_var(buf, 'lsp:keys_attached')
  end) ~= true then
    vim.api.nvim_buf_set_var(buf, 'lsp:keys_attached', true)
    key.register({
      g = {
        d = { vim.lsp.buf.definition, "Go to Definition" },
        D = { vim.lsp.buf.definition, "Go to Declaration" },
        y = { vim.lsp.buf.definition, "Go to Type Definition" },
        i = { vim.lsp.buf.definition, "Go to Implementation" },
        r = { "<cmd>TroubleToggle lsp_references<cr>", "Show References" },
        N = { vim.lsp.buf.rename, "Rename" },
        f = { vim.lsp.buf.code_action, "Code Action" },
      },
      K = { vim.lsp.buf.hover, "Hover" },
      ["C-k"] = { vim.lsp.buf.signature_help, "Signature Help" },
      ["[d"] = { vim.diagnostic.goto_prev, "Previous Diagnostic "},
      ["]d"] = { vim.diagnostic.goto_prev, "Next Diagnostic "},
    }, { buffer = buf })
  end
end

local function lsp_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.codeLens = { dynamicRegistration = false }
  capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown" }
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return require('cmp_nvim_lsp').update_capabilities(capabilities)
end

lsp.astro.setup({
  capabilities = lsp_capabilities(),
  on_attach = lsp_on_attach,
  cmd = { nix_bins.astrols, "--stdio" },
  flags = { debounce_text_changes = 200 },
})

lsp.tsserver.setup({
  capabilities = lsp_capabilities(),
  on_attach = lsp_on_attach,
  cmd = { nix_bins.tsserver, "--stdio" },
  flags = { debounce_text_changes = 200 },
  settings = {
    preferences = {
      disableAutomaticTypingAcquisition = true,
      importModuleSpecifierPreference = 'project-relative',
    },
  },
})

lsp.eslint.setup({
  capabilities = lsp_capabilities(),
  on_attach = lsp_on_attach,
  cmd = { nix_bins.eslintls, "--stdio" },
  flags = { debounce_text_changes = 200 },
  settings = {
    rulesCustomizations = {
      { rule = "prettier/prettier", severity = "off" },
      { rule = "sort-keys", severity = "off" },
      { rule = "quotes", severity = "off" },
      { rule = "max-len", severity = "off" },
      { rule = "no-tabs", severity = "off" },
    }
  },
})

lsp.vimls.setup({
  capabilities = lsp_capabilities(),
  on_attach = lsp_on_attach,
  cmd = { nix_bins.vimls, "--stdio" },
  flags = { debounce_text_changes = 200 },
})

lsp.rust_analyzer.setup({
  capabilities = lsp_capabilities(),
  on_attach = lsp_on_attach,
  cmd = { nix_bins.rustanalyzer },
  flags = { debounce_text_changes = 200 },
  settings = {
    ["rust-analyzer"] = {
      assist = {
        importGranularity = "module",
        importPrefix = "self",
      },
      cargo = {
        loadOutDirsFromCheck = true,
      },
      procMacro = {
        enable = true,
      },
    },
  },
})

-- null-ls
require('null-ls').setup({
  on_attach = lsp_on_attach,
  sources = {
    require('null-ls').builtins.code_actions.gitsigns,
  },
})

-- treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "astro",
    "typescript",
    "tsx",
    "graphql",
    "regex",
    "json",
    "json5",
    "javascript",
    "markdown",
    "markdown_inline",
    "yaml",
    "vue",
    "vim",
    "lua",
    "make",
    "jsdoc",
    "comment",
    "css",
    "sql",
    "rust",
    "html",
    "bash",
    "c",
    "nix"
  },
  highlight = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = "]",
      scope_incremental = "=",
      node_decremental = "[",
    },
  },
  refactor = {
    highlight_definitions = { enable = true },
    smart_rename = { enable = true, keymaps = { smart_rename = "gn" } },
  },
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@call.outer",
        ["ic"] = "@call.inner",
      },
    },
  },
}

-- lspkind
require('lspkind').init {
  mode = 'symbol_text',
  preset = 'codicons',
}

-- treesitter context
require('treesitter-context').setup {
  enable = true,
  throttle = true,
  max_lines = 1,
  patterns = {
    default = {
      'class',
      'function',
      'method',
    },
  },
}

-- lir settings
local lir_actions = require('lir.actions')
require('lir').setup {
  show_hidden_files = false,
  devicons_enable = false,
  hide_cursor = true,
  mappings = {
    ['l'] = lir_actions.edit,
    ['<cr>'] = lir_actions.edit,
    ['h'] = lir_actions.up,
    ['-'] = lir_actions.up,
    ['<esc>'] = lir_actions.quit,
    ['<c-c>'] = lir_actions.quit,
    ['@'] = lir_actions.cd,
    ['.'] = lir_actions.toggle_show_hidden,
  },
  on_init = function()
    -- hide statusline for lir
    vim.api.nvim_exec([[
      let &l:statusline='%{getline(line("w$")+1)}'
    ]], false)
  end,
}

-- hide sticky commands
vim.api.nvim_exec([[
  function! CursorHoldDelay(timer)
    if mode() ==# 'n'
      echon ''
    endif
  endfunction
  autocmd CursorHold * call timer_start(3000, funcref('CursorHoldDelay'))
]], false)

-- customise fold text
vim.api.nvim_exec([[
  function! FoldText()
    let nl = v:foldend - v:foldstart + 1
    let start = substitute(getline(v:foldstart), "^ *", "", 1)
    let end = substitute(getline(v:foldend),"^ *", "", 1)
    let txt = '  ' . start . ' … ' . end . ' (' . nl . ' lines) '
    return txt
  endfunction
  set foldtext=FoldText()
]], false)

-- completion
local cmp = require('cmp')
local snippy = require('snippy')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup {
  enabled = function()
    local context = require('cmp.config.context')
    if vim.api.nvim_get_mode().mode == 'c' then
      return true
    else
      return not context.in_treesitter_capture('comment')
        and not context.in_syntax_group('Comment')
    end
  end,
  preselect = cmp.PreselectMode.None,
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-c>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.close()
      end
      fallback()
    end, {"i", "c"}),
    ['<CR>'] = cmp.mapping({
      i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
      c = function(fallback)
        if cmp.visible() then
          cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
        else
          fallback()
        end
      end
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif snippy.can_expand_or_advance() then
        snippy.expand_or_advance()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {"i", "s"}),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif snippy.can_jump(-1) then
        snippy.previous()
      else
        fallback()
      end
    end, {"i", "s"}),
  }),
  snippet = {
    expand = function(args)
      snippy.expand_snippet(args.body)
    end,
  },
  completion = {
    keyword_length = 3
  },
  experimental = {
    ghost_text = true,
  },
  sources = cmp.config.sources(
    {{ name = 'nvim_lsp' }, { name = 'nvim_lsp_signature_help' }, { name = 'snippy' }},
    {{ name = 'treesitter' }, { name = 'buffer', keyword_length = 3 }}
  ),
  formatting = {
    format = require('lspkind').cmp_format(),
  },
}

cmp.setup.filetype('gitcommit', {
  enabled = false,
})

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline({
    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
      end
      fallback()
    end, {"i", "c"})
  }),
  sources = cmp.config.sources(
    {{ name = 'nvim_lsp_document_symbol' }},
    {{ name = 'cmdline_history' }},
    {{ name = 'treesitter' }, { name = 'buffer', keyword_length = 3 }}
  ),
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline({
    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
      end
      fallback()
    end, {"i", "c"})
  }),
  sources = cmp.config.sources(
    {{ name = 'path' }},
    {{ name = 'cmdline' }, { name = 'cmdline_history' }}
  ),
})

-- gitsigns
require('gitsigns').setup {
  signcolumn = true,
  numhl      = false,
  linehl     = false,
  word_diff  = false,
  current_line_blame = false,
  signs = {
    add = { hl = 'GitSignsAdd', text = '│' },
    change = { hl = 'GitSignsChange', text = '│' },
    delete = { hl = 'GitSignsDelete', text = '' },
    topdelete = { hl = 'GitSignsDelete', text = '' },
    changedelete = { hl = 'GitSignsChange', text = '' },
  },
  preview_config = {
    border = 'none',
    style = 'minimal',
    relative = 'cursor',
    row = 1,
    col = 0
  },
  on_attach = function(buf)
    local actions = require('gitsigns.actions')

    key.register({
      ["]c"] = { actions.next_hunk, "Next Git Hunk" },
      ["[c"] = { actions.next_hunk, "Previous Git Hunk" },
      g = {
        b = { function() actions.blame_line({ full = true }) end, "Blame Line" },
        h = { function() actions.preview_hunk(true) end, "Show Git Hunk" },
        s = { actions.stage_hunk, "Stage Git Hunk" },
        S = { actions.undo_stage_hunk, "Unstage Git Hunk" },
        t = { actions.diffthis, "Diff against HEAD" },
        T = { function() actions.diffthis('~') end, "Diff against HEAD~1" },
      },
    }, { buffer = buf })

    key.register({
      ["ih"] = {
        "<cmd><c-u>lua require('gitsigns.actions').select_hunk()<cr>",
        "Select Git Hunk"
      },
    }, { buffer = buf, mode = "o" })

    key.register({
      ["ih"] = {
        "<cmd><c-u>lua require('gitsigns.actions').select_hunk()<cr>",
        "Select Git Hunk"
      }
    }, { buffer = buf, mode = "x" })
  end,
}

-- hardline
local function status_diagnostic_handler(prefix, severity)
  return function()
    local count = #vim.diagnostic.get(0, { severity = severity })
    if count > 0 then
      return string.format('%s %d', prefix, count)
    else
      return ''
    end
  end
end

local function status_git()
  local b = vim.b
  if b.gitsigns_status_dict then
    return table.concat({
      hi('GitGutterAdd', string.format(' %d', b.gitsigns_status_dict.added or 0)),
      hi('GitGutterChange', string.format(' %d', b.gitsigns_status_dict.changed or 0)),
      hi('GitGutterDelete', string.format(' %d', b.gitsigns_status_dict.removed or 0)),
      hi('DiagnosticSignInformation', b.gitsigns_head ~= nil and string.format('( %s)', b.gitsigns_head) or ''),
    }, ' ')
  else
    return ''
  end
end

local function status_filetype()
  return (vim.bo.filetype ~= '' and string.format('  %s', vim.bo.filetype) or '')
end

local function status_progress()
  local blocks = {'█', '▇', '▆', '▅', '▄', '▃', '▂', '▁', ' '}
  local nbline = vim.fn.line('$')
  local line = vim.fn.line('.')
  local progress = blocks[math.ceil(line / (nbline / 9))]
  return nbline ~= 1 and table.concat({
    string.format('%s%d/%d', string.rep('·', #tostring(nbline) - #tostring(line)), line, nbline),
    progress,
  }, ' ') or ''
end

require('hardline').setup {
  bufferline = false,
  theme = vim.tbl_deep_extend(
    "force",
    require('hardline.themes.custom_colors').set(hardline_colors),
    {
      mode = {
        inactive = {
          guibg = hardline_colors.inactive_menu.gui,
          ctermbg = hardline_colors.inactive_menu.cterm,
        },
      },
    }
  ),
  sections = {
    {class = 'mode', item = require('hardline.parts.mode').get_item},
    {class = 'high', item = function() return vim.fn.expand('%:~:.') end },
    {class = 'med', item = status_git, hide = 100},
    '%<',
    {class = 'med', item = '%='},
    {class = 'error', item = status_diagnostic_handler('', vim.diagnostic.severity.ERROR) },
    {class = 'warning', item = status_diagnostic_handler('', vim.diagnostic.severity.WARN) },
    {class = 'high', item = status_filetype, hide = 80},
    {class = 'mode', item = status_progress },
  },
}

-- trouble
require('trouble').setup {
  height = 13,
  fold_open = "",
  fold_closed = "",
  padding = false,
  indent_lines = false,
  icons = false,
  signs = {
    error = "",
    warning = "",
    hint = "",
    information = "",
    other = ""
  },
  action_keys = {
    cancel = {},
    close = {"<esc>", "<c-c>"},
    close_folds = {"zM", "zm"},
    open_folds = {"zR", "zr", "zn"},
    toggle_fold = {"zA", "za", "<bar>", "<bslash>"},
    previous = {"k", "<s-tab>"},
    next = {"j", "<tab>"},
  },
}

-- dressing
require('dressing').setup {
  select = {
    telescope = require('telescope.themes').get_cursor(),
  },
}
