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

  vim-golden-size = buildVimPluginFrom2Nix {
    pname = "vim-golden-size";
    version = "2020-04-29";
    src = fetchFromGitHub {
      owner = "dm1try";
      repo = "golden_size";
      rev = "301907c3bd877912ca3d4125c602a23f8c4a7c95";
      sha256 = "01fqm86hjgfhh5i7xrkphn7mpv4fwcq0xij3qhvhbh4xbfwpr49l";
    };
    meta.homepage = "https://github.com/dm1try/golden_size";
  };

  defx-nvim = buildVimPluginFrom2Nix {
    pname = "defx-nvim";
    version = "2021-03-15";
    src = fetchFromGitHub {
      owner = "shougo";
      repo = "defx.nvim";
      rev = "6224e6981dc33887bc045a7eab7df6f94106c4af";
      sha256 = "0spj16d6n4swxcq2iv48si5l3pahmx6wypp4yc2mnaj2yxcjr39p";
    };
    meta.homepage = "https://github.com/Shougo/defx.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2021-03-15";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "2768ba75b32389a460273fab6f45575237b97bc2";
      sha256 = "14l47j8j5idm170vk92j72ndmkkn0gqjp709yb1b731nsnz9wcjh";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim";
  };

  popup-nvim = buildVimPluginFrom2Nix {
    pname = "popup-nvim";
    version = "2021-03-09";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "popup.nvim";
      rev = "bc98ca6df9179452c368f0d7bac821a8fd4c01ac";
      sha256 = "0j1gkaba6z5vb922j47i7sq0d1zwkr5581w0nxd8c31klghg3kyn";
    };
    meta.homepage = "https://github.com/nvim-lua/popup.nvim";
  };

  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-nvim";
    version = "2021-03-18";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "d4bf1181ea6ef9aec675ff404d65098cbb91d9b1";
      sha256 = "0q4v0mdha0gd2nbddxf8kzqc6kmzjwsv79zd22gm2dygdayr490i";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim";
  };

  completion-nvim = buildVimPluginFrom2Nix {
    pname = "completion-nvim";
    version = "2021-01-15";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "completion-nvim";
      rev = "fc9b2fd2d47bea6a8954de1b1b19f2330545b354";
      sha256 = "0dip8z6cfhjbz5lvf6f75382lg7d819djrpygbc12lf1s4i66i3z";
    };
    meta.homepage = "https://github.com/nvim-lua/completion-nvim";
  };

  completion-buffers = buildVimPluginFrom2Nix {
    pname = "completion-buffers";
    version = "2020-09-27";
    src = fetchFromGitHub {
      owner = "steelsojka";
      repo = "completion-buffers";
      rev = "441a58b77c04409e8ccb35fd4970598ae551462f";
      sha256 = "14q5n7h5kaqf71cfd9mlhwb0xsihm6d3kizrxhlfnzxk6zkn8p0s";
    };
    meta.homepage = "https://github.com/steelsojka/completion-buffers";
  };

  completion-treesitter = buildVimPluginFrom2Nix {
    pname = "completion-treesitter";
    version = "2020-06-26";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "completion-treesitter";
      rev = "45c9b2faff4785539a0d0c655440c2465fed985a";
      sha256 = "19pgdzzk7zq85b1grfjf0nncvs5vxrd4rj1p90iw2amq4mvqrx3l";
    };
    meta.homepage = "https://github.com/nvim-treesitter/completion-treesitter";
  };

  lsp-status-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-status.nvim";
    version = "2021-03-13";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "lsp-status.nvim";
      rev = "0aaf6a68e8668c1baa724c0d31679ad12f27cd47";
      sha256 = "08dlfm3f9qa4p77zznmgjrmx09yngpcfzmxmyc5z3gp51b6bbixb";
    };
    meta.homepage = "https://github.com/nvim-lua/lsp-status.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2020-03-15";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "26c499916ddac29675d316a099b376abf6a0aeaf";
      sha256 = "1z8dqcc38hxiakx5w06vzvgkf6zcy8w1ivzjj5dxxwh6l6p1ppvs";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2021-03-17";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "3e95cbca8544e9ee44c85d7f9c82a2254fbe6fe7";
      sha256 = "1sa1vq2626l54xkhfjvl9bz619i491ahvn34539bad77hndmwp4n";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter";
  };

  nvim-treesitter-refactor = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-refactor";
    version = "2021-03-17";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-refactor";
      rev = "edf1790d9cd365785d4f86848c079704aa7e4854";
      sha256 = "12rp2mj7va5qf55jzca0rgy1xrwkyf7p3zd3xw262m9lqm4hjqqc";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-refactor";
  };

  nvim-treesitter-textobjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textobjects";
    version = "2021-03-16";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "29b9e29cef885293ba02a590ba1f6618df8c3018";
      sha256 = "0gnpkdglm2y35n6ffmb0mj70j7ka94x8y2xl46z5d3312iimi30c";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };
}
