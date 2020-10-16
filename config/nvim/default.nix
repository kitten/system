{ pkgs, fetchgit, ... }:

let
  basic = builtins.readFile ./basic.vim;
  theme = builtins.readFile ./theme.vim;
  plugins = builtins.readFile ./plugins.vim;
  keymap = builtins.readFile ./keymap.vim;
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
          { name = "coc-nvim"; }
        ];
      };
    }
  )];
}
