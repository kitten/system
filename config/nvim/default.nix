{ pkgs, fetchgit, ... }:

let
  colors = import ../colors.nix;

  vim-basic = builtins.readFile ./basic.vim;
  vim-theme = builtins.readFile ./theme.vim;
  vim-plugins = builtins.readFile ./plugins.vim;
  vim-keymap = builtins.readFile ./keymap.vim;

  my-theme = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "my-theme";
    version = "2020-10-23";
    src = pkgs.writeTextFile {
      name = "theme.vim";
      text = colors.vim;
      destination = "/colors/theme.vim";
    };
  };

  vim-lsp = ("lua <<EOF\n" + ''
    local completion = require('completion')
    local lsp = require('lspconfig')
    local lsp_configs = require('lspconfig/configs')
    local lsp_util = require('lspconfig/util')

    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        update_in_insert = false,
      }
    )

    local on_attach = function(client, bufnr)
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

      completion.on_attach(client, bufnr)

      buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
      buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      buf_set_keymap('n', 'gy', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
      buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
      buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
      buf_set_keymap('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
      buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
      buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    end

    lsp_configs.prosemd = {
      default_config = {
        cmd = { "/Users/phil/Development/prosemd-lsp/target/release/prosemd-lsp", "--stdio" },
        filetypes = { "markdown" },
        root_dir = function(fname)
          return lsp_util.find_git_ancestor(fname) or vim.fn.getcwd()
        end,
        settings = {},
      }
    }

    lsp.prosemd.setup{
      on_attach = on_attach
    }

    lsp.tsserver.setup{
      on_attach = on_attach,
      cmd = { "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server", "--stdio" }
    }

    lsp.vimls.setup{
      on_attach = on_attach,
      cmd = { "${pkgs.nodePackages.vim-language-server}/bin/vim-language-server", "--stdio" }
    }

    lsp.rls.setup{
      on_attach = on_attach,
      cmd = { "${pkgs.rls}/bin/rls" }
    }

    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "typescript", "tsx", "graphql", "regex", "json", "javascript", "jsdoc", "css", "rust" },
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
  '' + "\nEOF");
in {
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    ripgrep
    bat
    (neovim.override {
      viAlias = true;
      vimAlias = true;

      configure = {
        customRC = ''
          ${vim-basic}
          ${colors.vim-lightline}
          ${vim-theme}
          ${vim-lsp}
          ${vim-plugins}
          ${vim-keymap}
        '';

        vam.knownPlugins = pkgs.vimPlugins // { my-theme = my-theme; };
        vam.pluginDictionaries = [
          { name = "my-theme"; }
          { name = "vim-repeat"; }
          { name = "editorconfig-vim"; }
          { name = "vim-purge-undodir"; }
          { name = "lightline-vim"; }
          { name = "vitality-vim"; }
          { name = "vim-zipper"; }
          { name = "vim-fugitive"; }
          { name = "vim-polyglot"; }
          { name = "vim-easymotion"; }
          { name = "nvim-lspconfig"; }
          { name = "vim-golden-size"; }
          { name = "defx-nvim"; }
          { name = "plenary-nvim"; }
          { name = "popup-nvim"; }
          { name = "telescope-nvim"; }
          { name = "completion-nvim"; }
          { name = "completion-buffers"; }
          { name = "completion-treesitter"; }
          { name = "nvim-treesitter"; }
          { name = "nvim-treesitter-refactor"; }
          { name = "nvim-treesitter-textobjects"; }
        ];
      };
    })
  ];
}
