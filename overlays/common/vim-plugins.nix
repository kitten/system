{
  fetchFromGitHub,
  buildVimPluginFrom2Nix,
}:

{
  vim-purge-undodir = buildVimPluginFrom2Nix {
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

  vitality-vim = buildVimPluginFrom2Nix {
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

  vim-zipper = buildVimPluginFrom2Nix {
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

  vim-golden-ratio = buildVimPluginFrom2Nix {
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

  vim-listtoggle = buildVimPluginFrom2Nix {
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

  deoplete-nvim = buildVimPluginFrom2Nix {
    pname = "deoplete-nvim";
    version = "2020-10-16";
    src = fetchFromGitHub {
      owner = "shougo";
      repo = "deoplete.nvim";
      rev = "8d208ee0c4e9697b8482f35494e557cd5955e6f5";
      sha256 = "1ywah5ql78jf9n3hlw1ksh2jmh6f7j4blxgr55sazp68wa88k2y8";
    };
    meta.homepage = "https://github.com/Shougo/deoplete.nvim";
  };

  deoplete-lsp = buildVimPluginFrom2Nix {
    pname = "deoplete-lsp";
    version = "2020-09-18";
    src = fetchFromGitHub {
      owner = "shougo";
      repo = "deoplete-lsp";
      rev = "17cd3fae3044eb8148bc22167257d4ae13165eb1";
      sha256 = "1xag51j71ifjn64xyaz7whml796pdl8vsw0ad22wndwzb95kyxdm";
    };
    meta.homepage = "https://github.com/Shougo/deoplete-lsp";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2020-09-07";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "60133c47e0fd82556d7ca092546ebfa8d047466e";
      sha256 = "15ysbbvxlgy1qx8rjv2i9pgjshldcs3m1ff0my2y5mnr3cpqb3s6";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };
}
