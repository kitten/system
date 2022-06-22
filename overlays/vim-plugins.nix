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
    version = "2022-05-30";
    src = fetchFromGitHub {
      owner = "dcampos";
      repo = "nvim-snippy";
      rev = "b13352f259c383cb1c921a1d5f2f98b072e53539";
      sha256 = "0cs0ir8xhivkqij25y4gf6zddq3c4j0qcdmv81k8lr1awfbr3017";
    };
    meta.homepage = "https://github.com/dcampos/nvim-snippy";
  };

  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2022-05-25";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "033a817ced907c8bcdcbe3355d7ea67446264f4b";
      sha256 = "0ywdjcic3ipc0igss3nmd9j2vdx3jh4wmfsx2895kasjb0x50fqg";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp";
  };

  nvim-cmp-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-treesitter";
    version = "2022-04-25";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "cmp-treesitter";
      rev = "c5187c31abd081ecef8b41e5eb476b7340442310";
      sha256 = "1jhzw7myrwqgybvkm53mk8zgfz56pzr7cnsrzcr4fl6wnm59a3b5";
    };
    meta.homepage = "https://github.com/ray-x/cmp-treesitter";
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

  nvim-cmp-lsp-document-symbol = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp-document-symbol";
    version = "2022-03-22";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-document-symbol";
      rev = "c3f0086ed9882e52e0ae38dd5afa915f69054941";
      sha256 = "1jprb86z081kpxyb2dhw3n1pq15dzcc9wlwmpb6k43mqd7k8q11l";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol";
  };

  nvim-cmp-lsp-signature-help = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp-signature-help";
    version = "2022-03-29";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-signature-help";
      rev = "8014f6d120f72fe0a135025c4d41e3fe41fd411b";
      sha256 = "1k61aw9mp012h625jqrf311vnsm2rg27k08lxa4nv8kp6nk7il29";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help";
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

  nvim-cmp-cmdline-history = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-cmdline-history";
    version = "2022-05-04";
    src = fetchFromGitHub {
      owner = "dmitmel";
      repo = "cmp-cmdline-history";
      rev = "003573b72d4635ce636234a826fa8c4ba2895ffe";
      sha256 = "1v2xyspm7k9jmnzbfg0js15c6sha7ravf4lddsk85icdw16fxji1";
    };
    meta.homepage = "https://github.com/dmitmel/cmp-cmdline-history";
  };

  hop-nvim = buildVimPluginFrom2Nix {
    pname = "hop-nvim";
    version = "2022-06-21";
    src = fetchFromGitHub {
      owner = "phaazon";
      repo = "hop.nvim";
      rev = "22137d92178c9dbda438be2751bf407b573d7bf2";
      sha256 = "1g7d5hp7rghapa3mnk3b79d8bws5rlklp12l629pqqqf5yg8xq33";
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
    version = "2022-06-20";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "3543443eb3856fbe4a9d70f3fe8dc73e007199a1";
      sha256 = "00mrf5qwbzgh280lq2lc7xgqmgh8g18j2f46796lbwpcb4ciawh4";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim";
  };

  trouble-nvim = buildVimPluginFrom2Nix {
    pname = "trouble-nvim";
    version = "2022-05-09";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "trouble.nvim";
      rev = "da61737d860ddc12f78e638152834487eabf0ee5";
      sha256 = "1aa45r9z8mghak8f5gymhm875rssi1afs92h0mpnn43y0j76xy31";
    };
    meta.homepage = "https://github.com/folke/trouble.nvim";
  };

  lir-nvim = buildVimPluginFrom2Nix {
    pname = "lir-nvim";
    version = "2022-04-20";
    src = fetchFromGitHub {
      owner = "tamago324";
      repo = "lir.nvim";
      rev = "41b57761d118ab919d265ad2983a696ca1081562";
      sha256 = "0rxdqbndzw0qkhy04w00mmb1wv1r2i13rq0msvz10rc3060lisvp";
    };
    meta.homepage = "https://github.com/tamago324/lir.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2022-06-12";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "968a4b9afec0c633bc369662e78f8c5db0eba249";
      sha256 = "05x9hnz960ljcb2psqycxgdmh99j36y16vbb9l92wjv5szkz37x5";
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
    version = "2022-06-18";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "c0a76f8a395b6461e3a28cff03687f125fd106ab";
      sha256 = "0sns0f7g253zcvmybdb89ir2sm04mx9ygzbflc4ypq616dilkq1f";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2022-06-22";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "9278dfbb92f8e99c313ce58ddcff92bd0bce5c0c";
      sha256 = "0bvy19kpv9wwj24khrl97rxgxkdw30rb013vpkxgq6gfnjjdh3sh";
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
    version = "2022-06-13";
    src = fetchFromGitHub {
      owner = "jose-elias-alvarez";
      repo = "null-ls.nvim";
      rev = "ff40739e5be6581899b43385997e39eecdbf9465";
      sha256 = "1snnh6fsn89fx7l5bjbfg1kh3cbadg2qg1rin889f4xka1yqa4x6";
    };
    meta.homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2022-06-22";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "238532fe82b3dbfedcc06f11a536e19b1df696e1";
      sha256 = "1jw66p151kfn5d7nf5l8h20pmw6hdlr91hflz21d38hjrafcyfcj";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter";
  };

  nvim-treesitter-refactor = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-refactor";
    version = "2022-05-13";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-refactor";
      rev = "75f5895cc662d61eb919da8050b7a0124400d589";
      sha256 = "1wpszy4mga9piq5c5ywgdw15wvff8l8a7a6agygfv1rahfv3087j";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-refactor";
  };

  nvim-treesitter-textobjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textobjects";
    version = "2022-05-23";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "b1e850b77e57b2720c06d523d6fc4776ad6a5608";
      sha256 = "070ldvra2xmg76nvx1xa5wx2pmfrfmjqbhxy2qpr6nyj0cbb5ndg";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };

  nvim-treesitter-context = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-context";
    version = "2022-06-20";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-context";
      rev = "b05cd9cbb972f48b583b581615a046f814ccaca0";
      sha256 = "07pxlms3j4kcd7ybmyjjkvjkkjxz084g3lm6kfv015pnca78wjj2";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-context";
  };

  impatient-nvim = buildVimPluginFrom2Nix {
    pname = "impatient-nvim";
    version = "2022-06-12";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "impatient.nvim";
      rev = "969f2c5c90457612c09cf2a13fee1adaa986d350";
      sha256 = "10nlz4hq1bqjsnj9pkadi3xjj74wn36f2vr66hqp7wm2z7i5zbq3";
    };
    meta.homepage = "https://github.com/lewis6991/impatient.nvim";
  };

  dressing-nvim = buildVimPluginFrom2Nix {
    pname = "dressing-nvim";
    version = "2022-05-18";
    src = fetchFromGitHub {
      owner = "stevearc";
      repo = "dressing.nvim";
      rev = "55e4ceae81d9169f46ea4452ce6e8c58cca00651";
      sha256 = "1i34pk9l76n8ianz9hww8kn7dnnzivv8sbyf0vf7w21r2bh1p1k4";
    };
    meta.homepage = "https://github.com/stevearc/dressing.nvim";
  };
}
