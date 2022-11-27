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

  initContents = "
    \nlua <<EOF\n" + ''
    require('impatient')

    nix_bins = {
      ripgrep = '${pkgs.ripgrep}/bin/rg',
      tsserver = '${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server',
      eslintls = '${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-eslint-language-server',
      cssls = '${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-css-language-server',
      htmlls = '${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-html-language-server',
      jsonls = '${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-json-language-server',
      astrols = '${pkgs.nodePackages."@astrojs/language-server"}/bin/astro-ls',
      rustanalyzer = '${pkgs.rust-analyzer}/bin/rust-analyzer'
    }

    hardline_colors = ${colors.vim-hardline}
  '' + (builtins.readFile ./init.lua) + "\nEOF";
in {
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    bat
    (neovim.override {
      viAlias = true;
      vimAlias = true;
      configure = {
        customRC = initContents;
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            my-theme
            impatient-nvim
            vim-repeat
            vim-fugitive
            editorconfig-vim
            hardline-nvim
            gitsigns-nvim
            nvim-lspconfig
            lspkind-nvim
            null-ls-nvim
            vim-golden-size
            lir-nvim
            plenary-nvim
            popup-nvim
            telescope-nvim
            trouble-nvim
            dressing-nvim
            hop-nvim
            which-key-nvim
            nvim-snippy
            nvim-cmp
            nvim-cmp-lsp
            nvim-cmp-lsp-document-symbol
            nvim-cmp-lsp-signature-help
            nvim-cmp-treesitter
            nvim-cmp-buffer
            nvim-cmp-path
            nvim-cmp-cmdline
            #nvim-cmp-cmdline-history
            nvim-cmp-snippy
            nvim-treesitter
            nvim-treesitter-refactor
            nvim-treesitter-textobjects
            nvim-treesitter-context
          ];
        };
      };
    })
  ];
}
