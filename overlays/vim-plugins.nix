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
    version = "2020-12-05";
    src = fetchFromGitHub {
      owner = "shougo";
      repo = "defx.nvim";
      rev = "0c5cff346fe81eda43e9ac4bb76b8f75b24d7b3e";
      sha256 = "05y51mvbhmmw05ssjybr1grjg1fmhh38zvq011i2w27xya188kh7";
    };
    meta.homepage = "https://github.com/Shougo/defx.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2020-11-17";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "7d555b5dad0376dd075e19f26e4e40705efe5dba";
      sha256 = "0c2i6lp17lgsrivacix1jcis2bh12wsg0hgmssdhmq8vr43q14sk";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim";
  };

  popup-nvim = buildVimPluginFrom2Nix {
    pname = "popup-nvim";
    version = "2020-10-09";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "popup.nvim";
      rev = "8f128cc7b2a1d759ce343ef92ea311526c6bbe13";
      sha256 = "1jxy6lp7r1wvd296x4ql6c9w43iwdwaf8jzyg5azs3x9cdyx9b73";
    };
    meta.homepage = "https://github.com/nvim-lua/popup.nvim";
  };

  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-nvim";
    version = "2020-12-03";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "telescope.nvim";
      rev = "655295ef64ebb0b769de45146dae65b89212a8f0";
      sha256 = "1avmkzn5bfn1zricvgnic9jdaizbb0nh970jl5bdszw80qilc6sn";
    };
    meta.homepage = "https://github.com/nvim-lua/telescope.nvim";
  };

  completion-nvim = buildVimPluginFrom2Nix {
    pname = "completion-nvim";
    version = "2020-11-20";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "completion-nvim";
      rev = "936bbd17577101a4ffb07ea7f860f77dd8007d43";
      sha256 = "1z399q3v36hx2ipj1fhxcc051pi4q0lifyglmclxi5zkbmm0z6a7";
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
    version = "2020-11-27";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "lsp-status.nvim";
      rev = "8efcef17230dd99efdee1048381dd88ea5681c95";
      sha256 = "17hdgy83g7yx936m9ncfbbwynz2c9zl3yqc0pbk64c4nc1sh4pzm";
    };
    meta.homepage = "https://github.com/nvim-lua/lsp-status.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2020-12-03";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "76f11625481eddb7bcbf86b3e4f592a1aef35b37";
      sha256 = "0ynkyyyzlmb4dmwd88gs47aqli2hq6j7y4905k0kpmsvfcfkpb36";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2020-12-07";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "3727be629ce1cac799ca740b95fe3aa484148018";
      sha256 = "113wiqcfpbxma5bca3fb1i62n9wyr5pvw2xf4l78frwavhn5i1xg";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter";
  };

  nvim-treesitter-refactor = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-refactor";
    version = "2020-10-16";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-refactor";
      rev = "9d4b9daf2f138a5de538ee094bd899591004f8e2";
      sha256 = "0ma5zsl70mi92b9y8nhgkppdiqfjj0bl3gklhjv1c3lg7kny7511";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-refactor";
  };

  nvim-treesitter-textobjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textobjects";
    version = "2020-12-03";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "af6c04593e15abcc462389420ba33b9a631ccfbf";
      sha256 = "187yjwqk5s6cs8lxrkd943jc5hda0fn69yv9srvvjz5w24rl41g5";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };
}
