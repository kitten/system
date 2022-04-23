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
    version = "2022-04-18";
    src = fetchFromGitHub {
      owner = "dcampos";
      repo = "nvim-snippy";
      rev = "11ed49b8cf527aee154fb583409b90fa270fc7f8";
      sha256 = "0hym8jd8zzw0lm3lgzan70agscn9lwy0jj5qksj8dahvkpc55aaw";
    };
    meta.homepage = "https://github.com/dcampos/nvim-snippy";
  };

  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2022-04-21";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "433af3dffce64cbd3f99bdac9734768a6cc41951";
      sha256 = "0r3va6syk6vfhs909p4r5p4h3ifyy5f4rk0m9jnvwblg9cjy17sw";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp";
  };

  nvim-cmp-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp";
    version = "2022-01-15";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "ebdfc204afb87f15ce3d3d3f5df0b8181443b5ba";
      sha256 = "0kmaxxdxlp1s5w36khnw0sdrbv1lr3p5n9r90h6h7wv842n4mnca";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp";
  };

  nvim-cmp-buffer = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-buffer";
    version = "2022-02-21";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "d66c4c2d376e5be99db68d2362cd94d250987525";
      sha256 = "0n9mqrf4rzj784zhshxr2wqyhm99d9mzalxqnik7srkghjvc9l4a";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-buffer";
  };

  nvim-cmp-path = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-path";
    version = "2022-02-02";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "466b6b8270f7ba89abd59f402c73f63c7331ff6e";
      sha256 = "15ksxnwxssv1yr1ss66mbl5w0layq0f4baisd9ki192alnkd7365";
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
    version = "2022-02-13";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "f4beb74e8e036f9532bedbcac0b93c7a55a0f8b0";
      sha256 = "0spc5vhrcz2ld1cxf9n27mhhfdwm0v89xbbyzbi9hshzfssndagh";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-cmdline";
  };

  hop-nvim = buildVimPluginFrom2Nix {
    pname = "hop-nvim";
    version = "2022-03-22";
    src = fetchFromGitHub {
      owner = "phaazon";
      repo = "hop.nvim";
      rev = "e2f978b50c2bd9ae2c6a4ebdf2222c0f299c85c3";
      sha256 = "1si2ibxidjn0l565vhr77949s16yjv46alq145b19h15amwgq3g2";
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
    version = "2022-04-22";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "ead0d48df801431b990d6b91fa210f7efa30ac38";
      sha256 = "1iq99bri0x38i641bn6xs9lhxjy1wgqzr6r1scbw2z6g1psqxq22";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim";
  };

  trouble-nvim = buildVimPluginFrom2Nix {
    pname = "trouble-nvim";
    version = "2022-03-18";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "trouble.nvim";
      rev = "691d490cc4eadc430d226fa7d77aaa84e2e0a125";
      sha256 = "1d218xxz936q53aknazhnfxhy9ncjyq76dna6y5n87kxn9hzqix1";
    };
    meta.homepage = "https://github.com/folke/trouble.nvim";
  };

  lir-nvim = buildVimPluginFrom2Nix {
    pname = "lir-nvim";
    version = "2022-04-20";
    src = fetchFromGitHub {
      owner = "tamago324";
      repo = "lir.nvim";
      rev = "43b2fae50a49fbf435899201b0c687b72ab2cc8f";
      sha256 = "0ayq5nj6mmxc4pd6sf49wllkr1bkgvx6dsdy0hl2f3w20sn5bpba";
    };
    meta.homepage = "https://github.com/tamago324/lir.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2022-04-17";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "9069d14a120cadb4f6825f76821533f2babcab92";
      sha256 = "0pgzi0brqn4kcbv1k5d50xm0bcwaq50sk5jnj3q9ls2pvv7lb9a0";
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
    version = "2022-04-22";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "8b02088743c07c2f82aec2772fbd2b3774195448";
      sha256 = "1ir6w7czd6xqk80nmppnpmykal78n8bjl1vjccp80zllrx3cidc7";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2022-04-17";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "ad9903c66bac88f344890acb6532f63f1cd4dac3";
      sha256 = "10fg52g53yk0d10rm96kw907wdkgqw762ib6530zrnw7p8fbm2ms";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  lspkind-nvim = buildVimPluginFrom2Nix {
    pname = "lspkind-nvim";
    version = "2022-04-18";
    src = fetchFromGitHub {
      owner = "onsails";
      repo = "lspkind-nvim";
      rev = "57e5b5dfbe991151b07d272a06e365a77cc3d0e7";
      sha256 = "1c13ll09v16prhzgmv8pappck4x3ahhc5sizp6r61kb7k4mkfpfk";
    };
    meta.homepage = "https://github.com/onsails/lspkind-nvim";
  };

  null-ls-nvim = buildVimPluginFrom2Nix {
    pname = "null-ls-nvim";
    version = "2022-04-22";
    src = fetchFromGitHub {
      owner = "jose-elias-alvarez";
      repo = "null-ls.nvim";
      rev = "0c7624fce3fefe291c75f0b6be2c1a51e5bed21e";
      sha256 = "0sfyrgnqmfqxprcrwgkgx5yawdc8hc05kwkjhv2h1naddlv9jbm4";
    };
    meta.homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2022-04-23";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "909b5d26fddad5043e354046571e7c7353b53b61";
      sha256 = "1x1b7r73g41nqra4bar0k8alzawzc81xxcgj9cw05r3504imvnf4";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter";
  };

  nvim-treesitter-refactor = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-refactor";
    version = "2022-01-22";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-refactor";
      rev = "0dc8069641226904f9757de786a6ab2273eb73ea";
      sha256 = "193fk657wjxz7hfbkjw566bng62vv7432cjhb5rwcig04xd5izqm";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-refactor";
  };

  nvim-treesitter-textobjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textobjects";
    version = "2022-04-21";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "094e8ad3cc839e825f8dcc91352837653e365a8f";
      sha256 = "1i7d8yxqffv6rp6n66wqyb0bsrq916qlp88rn8bb92ykyxmjn8bz";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };

  nvim-treesitter-context = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-context";
    version = "2022-04-21";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "nvim-treesitter-context";
      rev = "42c905eee2ab1c3f3584315f3f7638610c2366b0";
      sha256 = "183pr5vzj0pyxchisfhc3c149jh74l5jsf9ralr7x4abcma2iw66";
    };
    meta.homepage = "https://github.com/romgrk/nvim-treesitter-context";
  };

  impatient-nvim = buildVimPluginFrom2Nix {
    pname = "impatient-nvim";
    version = "2022-03-31";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "impatient.nvim";
      rev = "2337df7d778e17a58d8709f651653b9039946d8d";
      sha256 = "06gz1qsdqil1f2wsfyslk8vsdxxjjrsak0gfar2298ardaqb3dhp";
    };
    meta.homepage = "https://github.com/lewis6991/impatient.nvim";
  };
}
