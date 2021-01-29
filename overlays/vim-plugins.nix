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
    version = "2021-01-29";
    src = fetchFromGitHub {
      owner = "shougo";
      repo = "defx.nvim";
      rev = "d65c78a3dc7276a62d0b8e8f68687aad4e0436bb";
      sha256 = "07k7fsfcf652mzv0jv9p7jzc6rmcxcgch8i7rdsrry7plc934nc6";
    };
    meta.homepage = "https://github.com/Shougo/defx.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2021-01-25";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "cf4537efbae62222d3cdd239b7105c8ed4361a14";
      sha256 = "0fg2jwqchyvhx52wavwk90i6dk9vf4i4xlbhz26g4a3pv7i5mhwj";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim";
  };

  popup-nvim = buildVimPluginFrom2Nix {
    pname = "popup-nvim";
    version = "2020-12-12";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "popup.nvim";
      rev = "6f8f4cf35278956de1095b0d10701c6b579a2a57";
      sha256 = "0mvcms1ica4kpl5na0cppk0advyq96707zj394wvlnnq18dnsj4z";
    };
    meta.homepage = "https://github.com/nvim-lua/popup.nvim";
  };

  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-nvim";
    version = "2021-01-28";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "9d4670c74898c6050546580c71211746b9bb8aa7";
      sha256 = "11xqb3azk3x10j2aizrzfkfjqhvsh8b7c0jwnxb07i4h9dx4il1s";
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
    version = "2021-01-05";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "lsp-status.nvim";
      rev = "5215ea78a5949b42b86bf474d33608de6b7594a3";
      sha256 = "05h8n0ggi55g4ri9jsa4210knds0rxp8ym2knlq3njy40q0jjaxd";
    };
    meta.homepage = "https://github.com/nvim-lua/lsp-status.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2020-01-27";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "14386b6da178582b709d1c79eef30c7771db1114";
      sha256 = "1rqxxhcmd3yr91pv7p8c9fyziygcsyzsjzn5x64vqv5j0a5c7l65";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2021-01-29";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "3bef806c1852cb4ccbb297e71ad1a7a1d762e1f8";
      sha256 = "1zm7pb4fivbs70wcs0zczrd1v72idj3j7hsx93482pcp73352nz9";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter";
  };

  nvim-treesitter-refactor = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-refactor";
    version = "2021-01-07";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-refactor";
      rev = "16bbe963d044ec94316679868e0988caa7b5b4c3";
      sha256 = "0jgasxphwi222ga73y3jh5zq9m95n74331jn8r3nv741lk2g0772";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-refactor";
  };

  nvim-treesitter-textobjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textobjects";
    version = "2021-01-01";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "065b342db053810ac7a5ee9740b891cfa05c380f";
      sha256 = "07yl5iin11snw2637860r9zva9yfn7qkljkv0sjfldm73afflds7";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };
}
