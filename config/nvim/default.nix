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
    local diagnostic = require('diagnostic')
    local completion = require('completion')
    local nvim_lsp = require('nvim_lsp')

    local on_attach = function(client, bufnr)
      diagnostic.on_attach(client, bufnr)
      completion.on_attach(client, bufnr)
    end

    nvim_lsp.tsserver.setup{
      on_attach = on_attach,
      cmd = { "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server", "--stdio" }
    }

    nvim_lsp.terraformls.setup{
      on_attach = on_attach,
      cmd = { "${pkgs.terraform-ls}/bin/terraform-ls" }
    }

    nvim_lsp.vimls.setup{
      on_attach = on_attach,
      cmd = { "${pkgs.nodePackages.vim-language-server}/bin/vim-language-server", "--stdio" }
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
          { name = "goyo-vim"; }
          { name = "limelight-vim"; }
          { name = "vim-fugitive"; }
          { name = "vim-polyglot"; }
          { name = "vim-easymotion"; }
          { name = "nvim-lspconfig"; }
          { name = "vim-golden-size"; }
          { name = "defx-nvim"; }
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
    })
  ];
}
