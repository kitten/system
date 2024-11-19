{ lib, config, pkgs, ... } @ inputs:

with lib;
let
  inherit (import ../../lib/colors.nix inputs) colors mkVimHardlineColors;
  inherit (import ./theme.nix inputs) my-theme;

  cfg = config.modules.nvim;

  initContents = "
    \nlua <<EOF\n" + /* lua */ ''
    nix_bins = {
      terraformls = '${pkgs.terraform-ls}/bin/terraform-ls',
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

  nvim-treesitter = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.astro p.typescript p.tsx p.git_rebase p.gitcommit p.gitignore
    p.gitattributes p.graphql p.regex p.json p.json5 p.javascript
    p.markdown p.markdown_inline p.terraform p.svelte p.prisma
    p.yaml p.vue p.vim p.lua p.make p.jsdoc p.comment p.css
    p.sql p.rust p.html p.bash p.c p.nix p.zig p.yuck p.go
  ])).overrideAttrs (_: {
    src = pkgs.nvim-plugins.nvim-treesitter;
  });

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    withPython3 = true;
    viAlias = true;
    vimAlias = true;
    extraMakeWrapperArgs = "--set TERM wezterm";
    customRC = initContents;
    plugins = with pkgs.nvim-plugins; [
      my-theme
      vim-repeat
      hardline-nvim
      gitsigns-nvim
      nvim-lspconfig
      lspkind-nvim
      vim-golden-size
      popup-nvim
      trouble-nvim
      dressing-nvim
      oil-nvim

      nvim-cmp
      nvim-cmp-lsp
      nvim-cmp-lsp-signature-help
      nvim-cmp-treesitter

      plenary-nvim
      telescope-nvim
      telescope-zf-native-nvim

      nvim-treesitter
      nvim-treesitter-refactor
      nvim-treesitter-textobjects
    ];
  };

  neovimPkg = pkgs.neovim-unwrapped;
  neovim = pkgs.wrapNeovimUnstable neovimPkg neovimConfig;
in {
  options.modules.nvim = {
    enable = mkOption {
      default = true;
      description = "Neovim";
      type = types.bool;
    };
    useCustomConfig = mkOption {
      default = cfg.enable;
      description = "Custom Configuration";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.variables = { EDITOR = "vim"; };

    environment.systemPackages = with pkgs; if cfg.useCustomConfig then [
      ripgrep
      fd
      bat
      neovim
    ] else [
      neovimPkg
    ];
  };
}
