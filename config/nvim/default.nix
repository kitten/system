{ pkgs, pkgs-unstable, fetchgit, ... }:

let
  basic = builtins.readFile ./basic.vim;
  theme = builtins.readFile ./theme.vim;
  plugins = builtins.readFile ./plugins.vim;
  keymap = builtins.readFile ./keymap.vim;

  lsp = ("lua <<EOF\n" + ''
    require'nvim_lsp'.tsserver.setup{
      cmd = { "${pkgs-unstable.nodePackages.typescript-language-server}/bin/typescript-language-server", "--stdio" }
    }

    require'nvim_lsp'.vimls.setup{
      cmd = { "${pkgs-unstable.nodePackages.vim-language-server}/bin/vim-language-server", "--stdio" }
    }
  '' + "\nEOF");
in {
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    fzf
    silver-searcher
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
          { name = "vim-golden-ratio"; }
          { name = "goyo-vim"; }
          { name = "limelight-vim"; }
          { name = "fzf-vim"; }
          { name = "vim-dirvish"; }
          { name = "vim-fugitive"; }
          { name = "vim-listtoggle"; }
          { name = "vim-polyglot"; }
          { name = "vim-easymotion"; }
          { name = "vim-surround"; }
          { name = "nvim-lspconfig"; }
          { name = "deoplete-nvim"; }
          { name = "deoplete-lsp"; }
        ];
      };
    }
  )];
}
