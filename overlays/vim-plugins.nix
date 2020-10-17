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
    version = "2020-10-11";
    src = fetchFromGitHub {
      owner = "shougo";
      repo = "defx.nvim";
      rev = "3e89447030e1be35d477d4378b3632a328ea2db0";
      sha256 = "157y778v2m3224d2777p1syczxw2vyd1sbjqaf589ff0sarqyh0j";
    };
    meta.homepage = "https://github.com/Shougo/defx.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2020-10-16";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "9dc605ec987122dc79fa22f6a3732a46b6567261";
      sha256 = "1hnz1g5s48mw1jw9lmvqwasy7g6qpnjjpqh84qwjfv4mzx5kc0lb";
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
    version = "2020-10-16";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "telescope.nvim";
      rev = "5a7a3147a4553146342aeb5a112c72606367fea5";
      sha256 = "05nid5ia1im0xi1nmzpyvsvn56hmbd95mr4dvmjjpnnnahm9lksx";
    };
    meta.homepage = "https://github.com/nvim-lua/telescope.nvim";
  };

  diagnostic-nvim = buildVimPluginFrom2Nix {
    pname = "diagnostic-nvim";
    version = "2020-10-01";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "diagnostic-nvim";
      rev = "bef1c6140563cb6416081b2517ae9953cd4e05ab";
      sha256 = "05f2hr3229zph3x9lhmabb9rzdf61r92f3ybj2gs40hfbak0c3pb";
    };
    meta.homepage = "https://github.com/nvim-lua/diagnostic-nvim";
  };

  completion-nvim = buildVimPluginFrom2Nix {
    pname = "completion-nvim";
    version = "2020-10-15";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "completion-nvim";
      rev = "fb169917228b1df184996c98525e893a60fa235d";
      sha256 = "1asspimdfkb1lskmzak5wb48w35hvmwccrky5sxd1832xzjqz7g8";
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
    version = "2020-08-03";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "lsp-status.nvim";
      rev = "e1a26944039040bf0f6e7716d19878ec1907f50a";
      sha256 = "0lpq7fr4qlxllq86k8w7n3mvnsvqvrbid0395znc9vj8g2nkpa32";
    };
    meta.homepage = "https://github.com/nvim-lua/lsp-status.nvim";
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

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2020-10-16";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "7f3276450be20ec3cd8241bdb9196659289c3d31";
      sha256 = "1akq19vbyjanwk8n6gm8hjavpvfx107ljlh2iznyrkcsf9821nm9";
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
    version = "2020-10-16";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "036fe1f64daa544681bb35ee45b20a8a5bc72a9a";
      sha256 = "1ag5rzknc0xpakggq1rvwnjhbjc1zrkfsqzs5qcr6v6c035p02pd";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };
}
