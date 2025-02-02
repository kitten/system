-- utilities
local function t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function hi(group, str)
  return str ~= '' and string.format('%%#%s#%s', group, str) or ''
end

vim.loader.enable()

-- terminal options
vim.api.nvim_exec([[
  set t_Co=256
  set t_ZH=^\[\[3m
  set t_ZR=^\[\[23m
  let &t_Cs = "\e\[4:3m"
  let &t_Ce = "\e\[4:0m"
  let &t_ut=''
]], false)

-- default save options
vim.o.hidden = true
vim.o.encoding = 'utf8'

-- scroll and mouse options
vim.o.mouse = 'a'
vim.o.scrolloff = 2

-- indentation options
vim.o.autoindent = true
vim.o.smartindent = false
vim.o.breakindent = true

-- default tab options
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2

-- tweak redraw timings
vim.o.lazyredraw = true
vim.o.updatetime = 500
vim.o.timeoutlen = 500

-- fold options
vim.o.foldenable = true
vim.o.foldmethod = 'indent'
vim.o.foldnestmax = 9
vim.o.foldlevelstart = 3

-- search options
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.infercase = true
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

-- disable matchparen
vim.o.showmatch = false
vim.g.loaded_matchparen = 1

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- no completion or startup messages
vim.o.shortmess = vim.o.shortmess .. 'WcCIAa'

-- line numbers
vim.wo.number = true

-- char options
vim.opt.fillchars = {
  vert = '│',
  diff = '╱',
  horiz = '─',
  horizup = '┴',
  horizdown = '┬',
  vertleft = '┤',
  vertright = '├',
  verthoriz = '┼',
  eob = ' ',
}
vim.opt.listchars = {
  nbsp = "␣",
  extends = "»",
  precedes = "«",
  tab = " ",
}
vim.o.list = true

-- splitting options
vim.go.diffopt = 'filler,vertical,foldcolumn:0,closeoff,indent-heuristic,iwhite,algorithm:patience'
vim.go.splitbelow = true
vim.go.splitright = true
vim.o.splitkeep = 'screen'
vim.o.switchbuf = 'uselast'
vim.o.previewheight = 5

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
vim.o.ruler = false
vim.o.termguicolors = true
vim.o.cmdheight = 0
vim.o.background = 'dark'
vim.wo.signcolumn = 'number'
vim.wo.cursorline = true
vim.cmd('colorscheme theme')

-- misc. options
vim.o.completeopt = 'menuone,noinsert,noselect,popup'
vim.o.pumheight = 10
vim.o.winblend  = 5
vim.o.backspace = 'indent,eol,start'
vim.o.virtualedit = 'block' -- Allow going past the end of line in visual block mode
vim.o.formatoptions = 'qjl1' -- Don't autoformat comments
vim.o.synmaxcol = 300 -- Don't highlight long lines
vim.o.path = '**' -- Use a recursive path (for :find)
vim.o.gdefault = true -- Use //g for replacements by default

-- wildmenu
vim.opt.wildignore:append(
  '*.png,*.jpg,*.jpeg,*.gif,*.wav,*.aiff,*.dll,*.pdb,*.mdb,*.so,*.swp,*.zip,*.gz,*.bz2,*.meta,*.svg,*.cache,*/.git/*'
)
vim.o.wildmenu = true
vim.o.wildmode = 'longest,list,full'

-- built-in ftplugins should not change my keybindings
vim.g.no_plugin_maps = true
vim.cmd.filetype({ args = { 'plugin', 'on' } })
vim.cmd.filetype({ args = { 'plugin', 'indent', 'on' } })

--- ripgrep
vim.o.grepprg = nix_bins.ripgrep .. ' --vimgrep --no-heading --smart-case'
vim.o.grepformat = "%f:%l:%c:%m,%f:%l:%m"

-- unmap special keys
local key_opt = { noremap = true, silent = true }

vim.keymap.set('', '<Space>', '<nop>', { noremap = true, silent = true })
vim.keymap.set('', '<F1>', '<nop>', { noremap = true, silent = true })

-- period command in visual mode
vim.keymap.set('x', '.', '<cmd>norm .<cr>', { noremap = true, silent = true })

-- match ctrl-c to escape
vim.keymap.set('', '<c-c>', '<esc>', { noremap = true, silent = true })
vim.keymap.set('!', '<c-c>', '<esc>', { noremap = true, silent = true })

-- window controls
vim.keymap.set('', '<c-w>,', ':vsp<cr>', { noremap = true, silent = true })
vim.keymap.set('', '<c-w>.', ':sp<cr>', { noremap = true, silent = true })

-- remap semicolon to colon
vim.keymap.set('n', ';', ':', { noremap = true, silent = true })

-- destructive x-commands
vim.keymap.set('', 'X', '"_d', { noremap = true, silent = true })
vim.keymap.set('n', 'XX', '"_dd', { noremap = true, silent = true })
vim.keymap.set('v', 'x', '"_d', { noremap = true, silent = true })
vim.keymap.set('n', 'x', 'v"_d', { noremap = true, silent = true })

-- clipboard controls
vim.keymap.set('x', 'Y', '"+y', { noremap = true, silent = true })
vim.keymap.set('x', '<m-c>', '"+y', { noremap = true, silent = true })
vim.keymap.set('x', '<m-v>', '"+p', { noremap = true, silent = true })
vim.keymap.set('n', '<m-v>', '"+P', { noremap = true, silent = true })

-- indentation in visual mode
vim.keymap.set('v', '<', '<gv', { noremap = true, silent = true })
vim.keymap.set('v', '>', '>gv', { noremap = true, silent = true })

-- swap visual gj, gk, with jk
vim.keymap.set({'n', 'x'}, 'j', [[v:count == 0 ? 'gj' : 'j']], { noremap = true, silent = true, expr = true })
vim.keymap.set({'n', 'x'}, 'k', [[v:count == 0 ? 'gk' : 'k']], { noremap = true, silent = true, expr = true})

-- macros per line
vim.keymap.set('v', '@', ':<C-u>execute ":\'<,\'>normal @".nr2char(getchar())<CR>', { noremap = true, silent = true })

-- fold controls
vim.keymap.set('n', '<bar>', '<cmd>norm zc<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<bslash>', '<cmd>norm za<cr>', { noremap = true, silent = true })

-- set space as leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- buffer controls
vim.keymap.set('n', '<leader>h', '<cmd>bp<cr>', { desc = 'Previous Buffer' })
vim.keymap.set('n', '<leader>l', '<cmd>bn<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>j', '<cmd>enew<cr>', { desc = 'New Buffer' })
vim.keymap.set('n', '<leader>k', '<cmd>bp <bar> bd #<cr>', { desc = 'Close Buffer' })

-- golden_size
local function ignore_trouble_window()
  local ft = vim.api.nvim_buf_get_option(0, 'filetype')
  if ft == 'Trouble' then
    return 1
  elseif ft == 'gitsigns-blame' then
    return 1
  end
end

require('golden_size').set_ignore_callbacks {
  { ignore_trouble_window },
  { require('golden_size').ignore_float_windows },
  { require('golden_size').ignore_by_window_flag },
}

-- markdown
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.o.whichwrap = 'h,l'
    vim.opt_local.linebreak = true
    vim.opt_local.formatoptions = vim.opt_local.formatoptions + 'tcn12'
  end,
})

-- telescope
require('telescope').load_extension('zf-native')
require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      nix_bins.ripgrep,
      '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case'
    },
    prompt_prefix = ' ',
    selection_caret = '→ ',
    mappings = {
      i = {
        ['<c-t>'] = require('trouble.sources.telescope').open,
        ['<c-c>'] = require('telescope.actions').close,
      },
      n = {
        ['<c-t>'] = require('trouble.sources.telescope').open,
        ['<esc>'] = require('telescope.actions').close,
      },
    },
  },
}

vim.keymap.set('n', '<leader>b', function()
  require('telescope.builtin').buffers()
end, { desc = 'Workspace Search' })

vim.keymap.set('n', '<leader>f', function()
  require('telescope.builtin').live_grep()
end, { desc = 'Workspace Search' })

vim.keymap.set('n', '<leader>n', function()
  require('telescope.builtin').lsp_document_symbols(
    require('telescope.themes').get_ivy({
      ignore_symbols = { 'variable', 'constant', 'property' },
    })
  )
end, { desc = 'Document Symbols' })

vim.keymap.set('n', '<leader>N', function()
  require('telescope.builtin').lsp_dynamic_workspace_symbols(
    require('telescope.themes').get_ivy({
      ignore_symbols = { 'variable', 'constant', 'property' },
    })
  )
end, { desc = 'Workspace Symbols' })

vim.keymap.set('n', '<leader>o', function()
  local telescope_builtins = require('telescope.builtin')
  vim.fn.system('git rev-parse --is-inside-work-tree')
  if vim.v.shell_error == 0 then
    telescope_builtins.git_files()
  else
    telescope_builtins.find_files()
  end
end, { desc = 'Workspace Files' })

-- define signs
vim.fn.sign_define("DiagnosticSignError", { text = "●", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "◐", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "○", texthl = "DiagnosticSignInfo" })

-- configure vim diagnostics
vim.diagnostic.config({
  underline = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = {
    severity = { min = vim.diagnostic.severity.W },
    source = 'if_many',
  },
  float = {
    show_header = true,
    source = 'if_many',
    border = 'rounded',
    focusable = false,
    severity_sort = true,
  },
})

vim.keymap.set('n', 'gk', vim.diagnostic.open_float, { desc = 'Show Diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous Diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })

-- customise hover window size
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  max_width = math.max(math.floor(vim.o.columns * 0.7), 100),
  max_height = math.max(math.floor(vim.o.lines * 0.3), 30),
})

-- register custom filetypes
vim.filetype.add({
  extension = {
    astro = 'astro',
    envrc = 'bash',
  },
  pattern = {
    ['.*/%.vscode/.*%.json'] = 'json5',
  },
})

-- lspconfig
local lsp = require('lspconfig')
local lsp_util = require('lspconfig.util')

local function lsp_on_attach(client, buf)
  if client.config.flags and not client.config.flags.allow_incremental_sync ~= nil then
    client.config.flags.allow_incremental_sync = true
  end

  vim.api.nvim_buf_set_option(buf, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
  vim.api.nvim_buf_set_option(buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_buf_set_option(buf, 'tagfunc', 'v:lua.vim.lsp.tagfunc')

  if pcall(function()
    return vim.api.nvim_buf_get_var(buf, 'lsp:keys_attached')
  end) ~= true then
    vim.api.nvim_buf_set_var(buf, 'lsp:keys_attached', true)

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition', buffer = buf })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration', buffer = buf })
    vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, { desc = 'Go to type definition', buffer = buf })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation', buffer = buf })
    vim.keymap.set('n', 'gn', vim.lsp.buf.rename, { desc = 'Rename', buffer = buf })
    vim.keymap.set('n', 'gf', vim.lsp.buf.code_action, { desc = 'Code Actions', buffer = buf })
    vim.keymap.set('n', 'gr', '<cmd>Trouble lsp open<cr>', { desc = 'Show references', buffer = buf })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = buf })
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = buf })
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = buf })
  end
end

local function lsp_capabilities(extends)
  local capabilities = vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    require('cmp_nvim_lsp').default_capabilities() or {},
    extends or {}
  )
  capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown" }
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
  capabilities.workspace.workspaceFolders = true
  return capabilities
end

local function lsp_setup(server, opts)
  local config = lsp[server]
  opts.autostart = false
  opts.capabilities = lsp_capabilities(opts.capabilities)
  opts.on_attach = lsp_on_attach
  config.setup(opts)

  local event
  local pattern
  if config.filetypes then
    event = 'FileType'
    pattern = table.concat(config.filetypes, ',')
  else
    event = 'BufReadPost'
    pattern = '*'
  end

  vim.api.nvim_create_autocmd(event, {
    pattern = pattern,
    callback = function(opt)
      if not vim.b[opt.buf or vim.api.nvim_get_current_buf()].big then
        config.manager:try_add(opt.buf)
      end
    end,
    group = lsp_group,
  })
end

lsp_setup('ts_ls', {
  cmd = { nix_bins.tsserver, "--stdio" },
  flags = { debounce_text_changes = 200 },
  single_file_support = false,
  init_options = {
    hostInfo = 'neovim',
    disableAutomaticTypingAcquisition = true,
    preferences = {
      importModuleSpecifierPreference = 'project-relative',
    },
  },
  root_dir = function(fname)
    if lsp_util.root_pattern('.flowconfig')(fname) ~= nil then
      return nil
    else
      return lsp_util.root_pattern('tsconfig.json', 'package.json', 'jsconfig.json', '.git')(fname)
    end
  end,
})

lsp_setup('flow', {
  cmd = { nix_bins.bunx, "--no-install", "flow", "lsp" },
  flags = { debounce_text_changes = 200 },
  single_file_support = false,
})

lsp_setup('eslint', {
  cmd = { nix_bins.eslintls, "--stdio" },
  flags = { debounce_text_changes = 200 },
  settings = {
    rulesCustomizations = {
      { rule = 'prettier/prettier', severity = 'off' },
      { rule = 'sort-keys', severity = 'off' },
      { rule = 'quotes', severity = 'off' },
      { rule = 'max-len', severity = 'off' },
      { rule = 'no-tabs', severity = 'off' },
    },
  },
})

lsp_setup('cssls', {
  cmd = { nix_bins.cssls, "--stdio" },
  flags = { debounce_text_changes = 200 },
})

lsp_setup('html', {
  cmd = { nix_bins.htmlls, "--stdio" },
  flags = { debounce_text_changes = 200 },
})

lsp_setup('jsonls', {
  cmd = { nix_bins.jsonls, "--stdio" },
  flags = { debounce_text_changes = 200 },
})

lsp_setup('rust_analyzer', {
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

lsp_setup('terraformls', {
  cmd = { nix_bins.terraformls },
  flags = { debounce_text_changes = 200 },
})

-- treesitter
vim.opt.runtimepath:append("~/.local/share/nvim/site/parser")

require('nvim-treesitter.install').compilers = { nix_bins.clang }

require('nvim-treesitter.configs').setup {
  auto_install = false,
  highlight = {
    enable = true,
    disable = function(lang, buf)
      return vim.b[buf].big
    end,
  },
  incremental_selection = {
    enable = true,
    disable = function(lang, buf)
      return vim.b[buf].big
    end,
    keymaps = {
      node_incremental = "]",
      scope_incremental = "=",
      node_decremental = "[",
    },
  },
  refactor = {
    highlight_definitions = {
      enable = true,
      disable = function(lang, buf)
        return vim.b[buf].big
      end,
    },
    smart_rename = {
      enable = true,
      disable = function(lang, buf)
        return vim.b[buf].big
      end,
      keymaps = { smart_rename = "gn" }
    },
  },
  textobjects = {
    select = {
      enable = true,
      disable = function(lang, buf)
        return vim.b[buf].big
      end,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@call.outer",
        ["ic"] = "@call.inner",
      },
    },
  },
}

vim.keymap.set('n', '<c-e', function()
  print(vim.inspect(vim.treesitter.get_captures_at_cursor(0)))
end, { desc = 'Output Treesitter Token' })

-- lspkind
require('lspkind').init {
  mode = 'symbol_text',
  preset = 'codicons',
}

-- file browser
require("oil").setup({
  default_file_explorer = true,
  delete_to_trash = false,
  skip_confirm_for_simple_edits = true,
  prompt_save_on_select_new_entry = true,
  cleanup_delay_ms = 2000,
  lsp_file_methods = {
    timeout_ms = 1000,
    autosave_changes = false,
  },
  constrain_cursor = 'editable',
  watch_for_changes = false,
  use_default_keymaps = true,
  view_options = {
    show_hidden = false,
    is_hidden_file = function(name, bufnr)
      return vim.startswith(name, '.')
    end,
    is_always_hidden = function(name, bufnr)
      return name == '.DS_Store'
    end,
    natural_order = true,
    case_insensitive = true,
    sort = {
      { 'type', 'asc' },
      { 'name', 'asc' },
    },
  },
  float = {
    preview_split = 'auto',
    border = 'none',
    win_options = {
      winblend = 5,
    },
  },
  preview = {
    border = 'none',
    win_options = { winblend = 5 },
    update_on_cursor_moved = true,
  },
  progress = {
    border = 'none',
    minimized_border = 'none',
    win_options = { winblend = 5 },
  },
  ssh = { border = 'none', },
  keymaps_help = { border = 'none' },
})

vim.keymap.set('n', '-', require('oil').open, { noremap = true, silent = true })

-- hide sticky commands
vim.api.nvim_create_autocmd({ 'CursorHold' }, {
  pattern = "*",
  callback = function()
    vim.defer_fn(function()
      if vim.api.nvim_get_mode().mode == 'n' then
        vim.cmd('echon ""')
      end
    end, 3000)
  end,
})

-- mark big buffers
vim.api.nvim_create_autocmd({ 'BufReadPre' }, {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    vim.b[buf].big = ok and stats and (stats.size > 100 * 1024)
    if vim.b[buf].big then
      vim.opt_local.spell = false
      vim.opt_local.showmatch = false
      vim.opt_local.undofile = false
      vim.opt_local.foldmethod = 'manual'
    end
  end,
})

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

-- autocompletion
local cmp = require('cmp')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup {
  enabled = function()
    local context = require('cmp.config.context')
    if vim.b[vim.api.nvim_get_current_buf()].big then
      return false
    elseif vim.api.nvim_get_mode().mode == 'c' then
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
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {"i", "s"}),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, {"i", "s"}),
  }),
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  completion = {
    keyword_length = 3
  },
  view = {
    entries = "native",
  },
  experimental = {
    ghost_text = {
      hl_group = 'GhostText',
    },
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lsp' },
    { name = 'treesitter' },
  }),
  formatting = {
    format = require('lspkind').cmp_format(),
  },
}

cmp.setup.filetype('gitcommit', {
  enabled = false,
})

-- gitsigns
require('gitsigns').setup {
  signcolumn = true,
  numhl      = false,
  linehl     = false,
  word_diff  = false,
  current_line_blame = false,
  signs = {
    add = { text = '│' },
    change = { text = '│' },
    delete = { text = '' },
    topdelete = { text = '' },
    changedelete = { text = '' },
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

    vim.keymap.set('n', ']c', function()
      require('gitsigns.actions').next_hunk()
    end, { desc = 'Next Git Hunk', buffer = buf })
    vim.keymap.set('n', '[c', function()
      require('gitsigns.actions').next_hunk()
    end, { desc = 'Previous Git Hunk', buffer = buf })
    vim.keymap.set('n', 'gb', function()
      require('gitsigns.actions').blame_line({ full = true })
    end, { desc = 'Blame Line', buffer = buf })
    vim.keymap.set('n', 'gB', function()
      require('gitsigns.actions').blame()
    end, { desc = 'Blame Buffer', buffer = buf })
    vim.keymap.set('n', 'gh', function()
      require('gitsigns.actions').preview_hunk(true)
    end, { desc = 'Show Git Hunk', buffer = buf })
    vim.keymap.set('n', 'gs', function()
      require('gitsigns.actions').stage_hunk()
    end, { desc = 'Stage Git Hunk', buffer = buf })
    vim.keymap.set('n', 'gS', function()
      require('gitsigns.actions').stage_hunk()
    end, { desc = 'Unstage Git Hunk', buffer = buf })
    vim.keymap.set('n', 'gt', function()
      require('gitsigns.actions').diffthis()
    end, { desc = 'Diff against HEAD', buffer = buf })
    vim.keymap.set('n', 'gT', function()
      require('gitsigns.actions').diffthis('~')
    end, { desc = 'Diff against HEAD~1', buffer = buf })
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
      hi('GitSignsAdd', string.format(' %d', b.gitsigns_status_dict.added or 0)),
      hi('GitSignsChange', string.format(' %d', b.gitsigns_status_dict.changed or 0)),
      hi('GitSignsDelete', string.format(' %d', b.gitsigns_status_dict.removed or 0)),
      hi('DiagnosticSignInfo', b.gitsigns_head ~= nil and string.format('( %s)', b.gitsigns_head) or ''),
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
  icons = {
    ---@type trouble.Indent.symbols
    indent = {
      top           = "│ ",
      middle        = "├╴",
      last          = "└╴",
      fold_open     = " ",
      fold_closed   = " ",
      ws            = "  ",
    },
    folder_closed   = " ",
    folder_open     = " ",
    kinds = {
      Array         = " ",
      Boolean       = " ",
      Class         = " ",
      Constant      = " ",
      Constructor   = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Function      = " ",
      Interface     = " ",
      Key           = " ",
      Method        = " ",
      Module        = " ",
      Namespace     = " ",
      Null          = " ",
      Number        = " ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      String        = " ",
      Struct        = " ",
      TypeParameter = " ",
      Variable      = " ",
    },
  },
}

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = "Trouble",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

vim.keymap.set('n', '<leader>q', '<cmd>Trouble qflist open<cr>', { desc = 'Quickfix list' })
vim.keymap.set('n', '<leader>p', '<cmd>Trouble loclist open<cr>', { desc = 'Location list' })
vim.keymap.set('n', '<leader>d', '<cmd>Trouble diagnostics open filter.buf=0<cr>', { desc = 'Document Diagnostics' })
vim.keymap.set('n', '<leader>D', '<cmd>Trouble diagnostics open<cr>', { desc = 'Workspace Diagnostics' })

-- dressing
require('dressing').setup {
  select = {
    backend = { "telescope", "builtin", "nui" },
    telescope = require('telescope.themes').get_cursor(),
  },
}
