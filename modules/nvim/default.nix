{ pkgs, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) colors mkVimHardlineColors;
  inherit (import ./theme.nix inputs) my-theme;

  initContents = "
    \nlua <<EOF\n" + ''
    nix_bins = {
      tsserver = '${pkgs.typescript-language-server}/bin/typescript-language-server',
      eslintls = '${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server',
      cssls = '${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server',
      htmlls = '${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server',
      jsonls = '${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server',
      bunx = '${pkgs.bun}/bin/bunx',
      ripgrep = '${pkgs.ripgrep}/bin/rg',
      rustanalyzer = '${pkgs.rust-analyzer}/bin/rust-analyzer',
    }

    hardline_colors = ${mkVimHardlineColors colors}
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
      extraMakeWrapperArgs = "--set TERM wezterm";
      configure = {
        customRC = initContents;
        packages.myVimPackage = with pkgs.nvim-plugins; {
          start = [
            my-theme
            vim-repeat
            vim-fugitive
            hardline-nvim
            gitsigns-nvim
            nvim-lspconfig
            lspkind-nvim
            vim-golden-size
            lir-nvim
            popup-nvim
            trouble-nvim
            dressing-nvim
            which-key-nvim

            nvim-cmp
            nvim-cmp-lsp
            nvim-cmp-lsp-document-symbol
            nvim-cmp-lsp-signature-help
            nvim-cmp-treesitter
            nvim-cmp-path
            nvim-cmp-cmdline
            nvim-cmp-snippy
            nvim-snippy

            nvim-treesitter-refactor
            nvim-treesitter-textobjects

            plenary-nvim
            telescope-nvim
            telescope-zf-native-nvim

            (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
              p.astro p.typescript p.tsx p.git_rebase p.gitcommit p.gitignore
              p.gitattributes p.graphql p.regex p.json p.json5 p.javascript
              p.markdown p.markdown_inline p.terraform p.svelte p.prisma
              p.yaml p.vue p.vim p.lua p.make p.jsdoc p.comment p.css
              p.sql p.rust p.html p.bash p.c p.nix p.zig p.yuck p.go
            ]))
          ];
        };
      };
    })
  ];
}
