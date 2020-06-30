{ pkgs, fetchgit, ... }:

let
  inherit (import <nixpkgs> {}) fetchFromGitHub;
  inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;

  plugins.vim-purge-undodir = buildVimPluginFrom2Nix {
    pname = "purge_undodir.vim";
    version = "2017-09-11";
    src = fetchFromGitHub {
      owner = "jsfaint";
      repo = "purge_undodir.vim";
      rev = "7115b2462b7738dd796e9febecbd24055793789f";
      sha256 = "1c20bk4g3a930pqs6w1wcw34wj7xpcp6zi1wkx7jadxqjjwgcclp";
    };
    meta.homepage = "https://github.com/jsfaint/purge_undodir.vim";
  };

  plugins.vitality-vim = buildVimPluginFrom2Nix {
    pname = "vitality.vim";
    version = "2017-01-30";
    src = fetchFromGitHub {
      owner = "sjl";
      repo = "vitality.vim";
      rev = "0f693bff572689ad52b781c012dad4926cd924f6";
      sha256 = "06zjlyp86clv3airxaw45d94kcrznd36m5r4dpj6lfrijwc4xhly";
    };
    meta.homepage = "https://github.com/sjl/vitality.vim";
  };

  plugins.vim-zipper = buildVimPluginFrom2Nix {
    pname = "vim-zipper";
    version = "2016-09-13";
    src = fetchFromGitHub {
      owner = "sts10";
      repo = "vim-zipper";
      rev = "5e60e2b39362168598db543f0c99bad930d5966f";
      sha256 = "088m30inpq9rwd0c7pyick7ibji2vdhdf4hzd6iy4c5z1mn9kch1";
    };
    meta.homepage = "https://github.com/sts10/vim-zipper";
  };

  plugins.vim-golden-ratio = buildVimPluginFrom2Nix {
    pname = "vim-golden-ratio";
    version = "2020-04-03";
    src = fetchFromGitHub {
      owner = "roman";
      repo = "golden-ratio";
      rev = "8313b6d6723c9e77ef1d3760af2cdd244e8db043";
      sha256 = "03nm1wr0qsrirg4z4171f4nygnqgb6w06ldr6rbbz4a1f7j8j654";
    };
    meta.homepage = "https://github.com/roman/golden-ratio";
  };

  plugins.vim-listtoggle = buildVimPluginFrom2Nix {
    pname = "vim-listtoggle";
    version = "2019-03-13";
    src = fetchFromGitHub {
      owner = "Valloric";
      repo = "ListToggle";
      rev = "63fb8acb57d57380b2e30e7a831247140559c95f";
      sha256 = "1fbshc3pjm0d1nnig2wnbj9yf39iagva44k2qhl85zfz1pv7sv57";
    };
    meta.homepage = "https://github.com/Valloric/ListToggle";
  };
in {
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    fzf
    silver-searcher
    (neovim.override {
      viAlias = true;
      vimAlias = true;

      configure = {
        customRC = pkgs.callPackage ./vimrc.nix {};
        vam.knownPlugins = pkgs.vimPlugins // plugins;
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
