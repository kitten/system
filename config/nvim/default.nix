{ pkgs, fetchgit, ... }:

let
  colors = import ../colors.nix;

  my-theme = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "my-theme";
    version = "2020-10-23";
    src = pkgs.writeTextFile {
      name = "theme.vim";
      text = colors.vim;
      destination = "/colors/theme.vim";
    };
  };

  initContents = "lua <<EOF\n" + ''
    require('impatient')

    nix_bins = {
      ripgrep = '${pkgs.ripgrep}/bin/rg',
      tsserver = '${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server',
      eslintls = '${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-eslint-language-server',
      vimls = '${pkgs.nodePackages.vim-language-server}/bin/vim-language-server',
      rustanalyzer = '${pkgs.rust-analyzer}/bin/rust-analyzer'
    }

    hardline_colors = ${colors.vim-hardline}
  '' + (builtins.readFile ./init.lua) + "\nEOF";
in {
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    ripgrep
    bat
    (neovim.override {
      viAlias = true;
      vimAlias = true;

      configure = {
        customRC = initContents;
        vam.knownPlugins = pkgs.vimPlugins // { my-theme = my-theme; };
        vam.pluginDictionaries = [
          { name = "my-theme"; }
          { name = "impatient-nvim"; }
          { name = "vim-repeat"; }
          { name = "vim-fugitive"; }
          { name = "editorconfig-vim"; }
          { name = "vim-polyglot"; }
          { name = "hardline-nvim"; }
          { name = "gitsigns-nvim"; }
          { name = "nvim-lspconfig"; }
          { name = "lspkind-nvim"; }
          { name = "null-ls-nvim"; }
          { name = "vim-golden-size"; }
          { name = "lir-nvim"; }
          { name = "plenary-nvim"; }
          { name = "popup-nvim"; }
          { name = "telescope-nvim"; }
          { name = "trouble-nvim"; }
          { name = "dressing-nvim"; }
          { name = "hop-nvim"; }
          { name = "which-key-nvim"; }
          { name = "nvim-snippy"; }
          { name = "nvim-cmp"; }
          { name = "nvim-cmp-lsp"; }
          { name = "nvim-cmp-lsp-document-symbol"; }
          { name = "nvim-cmp-lsp-signature-help"; }
          { name = "nvim-cmp-treesitter"; }
          { name = "nvim-cmp-buffer"; }
          { name = "nvim-cmp-path"; }
          { name = "nvim-cmp-cmdline"; }
          #{ name = "nvim-cmp-cmdline-history"; }
          { name = "nvim-cmp-snippy"; }
          { name = "nvim-treesitter"; }
          { name = "nvim-treesitter-refactor"; }
          { name = "nvim-treesitter-textobjects"; }
          { name = "nvim-treesitter-context"; }
        ];
      };
    })
  ];
}
