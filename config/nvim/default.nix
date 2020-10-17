{ pkgs, pkgs-unstable, fetchgit, ... }:

let
  basic = builtins.readFile ./basic.vim;
  theme = builtins.readFile ./theme.vim;
  plugins = builtins.readFile ./plugins.vim;
  keymap = builtins.readFile ./keymap.vim;

  lsp = ("lua <<EOF\n" + ''
    local diagnostic = require('diagnostic')
    local completion = require('completion')
    local nvim_lsp = require('nvim_lsp')

    local on_attach = function(client, bufnr)
      diagnostic.on_attach(client, bufnr)
      completion.on_attach(client, bufnr)
    end

    nvim_lsp.tsserver.setup{
      on_attach = on_attach,
      cmd = { "${pkgs-unstable.nodePackages.typescript-language-server}/bin/typescript-language-server", "--stdio" }
    }

    nvim_lsp.vimls.setup{
      on_attach = on_attach,
      cmd = { "${pkgs-unstable.nodePackages.vim-language-server}/bin/vim-language-server", "--stdio" }
    }

    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "typescript", "tsx", "regex", "json", "javascript", "css" },
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
          ${basic}
          ${theme}
          ${lsp}
          ${plugins}
          ${keymap}
        '';

        vam.knownPlugins = pkgs.vimPlugins;
        vam.pluginDictionaries = [
          { name = "palenight-vim"; }
          { name = "vim-repeat"; }
          { name = "editorconfig-vim"; }
          { name = "vim-purge-undodir"; }
          { name = "lightline-vim"; }
          { name = "vitality-vim"; }
          { name = "vim-zipper"; }
          { name = "goyo-vim"; }
          { name = "limelight-vim"; }
          { name = "vim-dirvish"; }
          { name = "vim-fugitive"; }
          { name = "vim-polyglot"; }
          { name = "vim-easymotion"; }
          { name = "nvim-lspconfig"; }
          { name = "vim-golden-size"; }
          { name = "plenary-nvim"; }
          { name = "popup-nvim"; }
          { name = "telescope-nvim"; }
          { name = "diagnostic-nvim"; }
          { name = "completion-nvim"; }
          { name = "completion-buffers"; }
          { name = "completion-treesitter"; }
          { name = "nvim-treesitter"; }
          { name = "nvim-treesitter-refactor"; }
          { name = "nvim-treesitter-textobjects"; }
        ];
      };
    }
  )];
}
