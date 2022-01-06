{
  fetchFromGitHub,
  buildVimPluginFrom2Nix,
}:

{
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

  nvim-snippy = buildVimPluginFrom2Nix {
    pname = "nvim-snippy";
    version = "2022-01-04";
    src = fetchFromGitHub {
      owner = "dcampos";
      repo = "nvim-snippy";
      rev = "73a03f56903f42b9350213ec66ed5dfd06e5f168";
      sha256 = "0j9yd0kjiiy2kd4pmsb3b93cd45hmx6dq89mk1fxbfmb1xc8zaj3";
    };
    meta.homepage = "https://github.com/dcampos/nvim-snippy";
  };

  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2022-01-02";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "1b94aacada96d2a33fef2ecf87748b27a2f50630";
      sha256 = "0ignbissria29ch9mdv1fsgg8cr77qwbnmzxhxsd6spyn5vbxlhv";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp";
  };

  nvim-cmp-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp";
    version = "2022-01-04";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "b4251f0fca1daeb6db5d60a23ca81507acf858c2";
      sha256 = "0qaz5rb062qyk1zn5ahx6f49yk0r0n0a4mnrlpdcil4kc9j6mfy6";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp";
  };

  nvim-cmp-buffer = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-buffer";
    version = "2022-01-04";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "f83773e2f433a923997c5faad7ea689ec24d1785";
      sha256 = "0z1c0x60hz3khgpp7nfj0i579sgi4vsnhhcqb02i7a8jx685qwrd";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-buffer";
  };

  nvim-cmp-path = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-path";
    version = "2021-12-30";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "4d58224e315426e5ac4c5b218ca86cab85f80c79";
      sha256 = "01bn7a04cnljsfls5v9yba6vz4wd2zvbi5jj063gasvqb7yq9kbp";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-path";
  };

  nvim-cmp-snippy = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-snippy";
    version = "2021-09-20";
    src = fetchFromGitHub {
      owner = "dcampos";
      repo = "cmp-snippy";
      rev = "9af1635fe40385ffa3dabf322039cb5ae1fd7d35";
      sha256 = "1ag31kvd2q1awasdrc6pbbbsf0l3c99crz4h03337wj1kcssiixy";
    };
    meta.homepage = "https://github.com/dcampos/cmp-snippy";
  };

  nvim-cmp-cmdline = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-cmdline";
    version = "2021-12-01";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "29ca81a6f0f288e6311b3377d9d9684d22eac2ec";
      sha256 = "0yzh0jdys1bn1c2mqm410c0ndyyyxpmigzdrkhnkv78b16vjyhq6";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-cmdline";
  };

  hop-nvim = buildVimPluginFrom2Nix {
    pname = "hop-nvim";
    version = "2022-01-04";
    src = fetchFromGitHub {
      owner = "phaazon";
      repo = "hop.nvim";
      rev = "443380545e3f86cafec01130b59afacfca9dad5c";
      sha256 = "0q88kz9yaslwa2kka70r3l8sbf60jllfhjlvm9cjx608nhdf0skz";
    };
    meta.homepage = "https://github.com/phaazon/hop.nvim";
  };

  hardline-nvim = buildVimPluginFrom2Nix {
    pname = "hardline-nvim";
    version = "2021-09-03";
    src = fetchFromGitHub {
      owner = "ojroques";
      repo = "nvim-hardline";
      rev = "9a6998ff2af04ee86cf87e710fd9daa279726bdc";
      sha256 = "1zh6ab0zvrs6jxivngq7l5lnz1g61h31y9bzibgmnq2ab6qm7rn9";
    };
    meta.homepage = "https://github.com/ojroques/nvim-hardline";
  };

  gitsigns-nvim = buildVimPluginFrom2Nix {
    pname = "gitsigns-nvim";
    version = "2021-12-30";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "c18fc65c77abf95ac2e7783b9e7455a7a2fab26c";
      sha256 = "1p589zfnqiycqcbp4kpvgr94p222rxif9lhsh00ic7c8hssf0j9h";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim";
  };

  trouble-nvim = buildVimPluginFrom2Nix {
    pname = "trouble-nvim";
    version = "2021-12-31";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "trouble.nvim";
      rev = "20469be985143d024c460d95326ebeff9971d714";
      sha256 = "00g1w1ry2gzklxvmvgy3dpig8njaziqz64yf7bqr9vqf0nxcvb5p";
    };
    meta.homepage = "https://github.com/folke/trouble.nvim";
  };

  lir-nvim = buildVimPluginFrom2Nix {
    pname = "lir-nvim";
    version = "2021-12-23";
    src = fetchFromGitHub {
      owner = "tamago324";
      repo = "lir.nvim";
      rev = "b4bc9ed23c9d71fc57ad6505d6c1cb4af1643051";
      sha256 = "11l50bkvfamq95jhw566iih5z5nrlypj8jrccmm05p3zwdzyvvy5";
    };
    meta.homepage = "https://github.com/tamago324/lir.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2022-01-05";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "563d9f6d083f0514548f2ac4ad1888326d0a1c66";
      sha256 = "1i4sj56fral52xa2wqzx331a6xza4ksi0n6092g6q93kxx202xwq";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim";
  };

  popup-nvim = buildVimPluginFrom2Nix {
    pname = "popup-nvim";
    version = "2021-11-18";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "popup.nvim";
      rev = "b7404d35d5d3548a82149238289fa71f7f6de4ac";
      sha256 = "093r3cy02gfp7sphrag59n3fjhns7xdsam1ngiwhwlig3bzv7mbl";
    };
    meta.homepage = "https://github.com/nvim-lua/popup.nvim";
  };

  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-nvim";
    version = "2022-01-03";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "a01ebd2793999c11d727fd15b1e5979ba20c7503";
      sha256 = "1xj3nr3rvsd6gx39284swxyhiw6s0kpis6dvp9g6fnwiiz5mbi38";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2022-01-05";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "9a122f640c4ae2610c9834327cbf6d1175a95712";
      sha256 = "1rf4zql7v7mgcrk8iz7ylkv26973qibphbgbn2q7i1y8d16axmx4";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  lspkind-nvim = buildVimPluginFrom2Nix {
    pname = "lspkind-nvim";
    version = "2021-12-30";
    src = fetchFromGitHub {
      owner = "onsails";
      repo = "lspkind-nvim";
      rev = "f0d1552890e384f15b47ea88bd1b8a077cddc24a";
      sha256 = "0wnkwh132cxnp9ppxlxrx87lykizx9mc00hg0zdvgys2h51kh050";
    };
    meta.homepage = "https://github.com/onsails/lspkind-nvim";
  };

  null-ls-nvim = buildVimPluginFrom2Nix {
    pname = "null-ls-nvim";
    version = "2022-01-05";
    src = fetchFromGitHub {
      owner = "jose-elias-alvarez";
      repo = "null-ls.nvim";
      rev = "b75effe6cb304e97901289f3f2e8d2ba77c7b752";
      sha256 = "02ay6j9shjdh8w59a4nyjq61amvmprhf24ylx84ld64plq2g3sz3";
    };
    meta.homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2022-01-05";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "b05803402965395cfab2c3e9c0258f494dac377d";
      sha256 = "098pzhc1xfq5bgxy1padliz22rqg073m4cqzyp343c1a2m4cibvm";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter";
  };

  nvim-treesitter-refactor = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-refactor";
    version = "2021-12-08";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-refactor";
      rev = "a21ed4d294d2da5472ce5b70385d7871c4518a1e";
      sha256 = "1hhl6gqq56q9lfgy581cwbhyiyqji4adbmhxmhwn7d5x0lv6bv24";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-refactor";
  };

  nvim-treesitter-textobjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textobjects";
    version = "2021-12-22";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "6ee11ac62681eb2eb8104a4ce509a9a861672cb5";
      sha256 = "0hgay8d4lja4fk3d6xhq08n1j9ic6flzq1w003b3fpxzr6l2b0vl";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };

  nvim-treesitter-context = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-context";
    version = "2021-10-05";
    src = fetchFromGitHub {
      owner = "romgrk";
      repo = "nvim-treesitter-context";
      rev = "e1f54e1627176337b3803a11403ac0e9d09de818";
      sha256 = "0xg3c8msd9fsmwlxgpxwbz2h9aizc3f7jn9p1q23pjlpcxr8xwll";
    };
    meta.homepage = "https://github.com/romgrk/nvim-treesitter-context";
  };

  impatient-nvim = buildVimPluginFrom2Nix {
    pname = "impatient-nvim";
    version = "2021-12-26";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "impatient.nvim";
      rev = "3ea9abedb6941995b05fdad654d9cfd51c38a31f";
      sha256 = "06b8h3g77wrjxvhapkvx149pha29a0zcq28bj2pcvh7686cysz9k";
    };
    meta.homepage = "https://github.com/lewis6991/impatient.nvim";
  };
}
