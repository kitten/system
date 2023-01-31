{
  fetchFromGitHub,
  buildVimPluginFrom2Nix,
}:

{
  vim-fugitive = buildVimPluginFrom2Nix {
    pname = "vim-fugitive";
    version = "2022-08-17";
    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-fugitive";
      rev = "b411b753f805b969cca856e2ae51fdbab49880df";
      sha256 = "0bcq71hfy08q4lq83rcrwpg7jkq0aszcbaqnjhphvg8wja5q30dm";
    };
    meta.homepage = "https://github.com/tpope/vim-fugitive";
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
    version = "2022-11-24";
    src = fetchFromGitHub {
      owner = "dcampos";
      repo = "nvim-snippy";
      rev = "7b98712fdebda8d20375359622e2cb2795f774d8";
      sha256 = "131ji85a14cd7f5gx41q76b2n1gvjbj0whlizpk3c62kz44mpgdp";
    };
    meta.homepage = "https://github.com/dcampos/nvim-snippy";
  };

  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2022-11-25";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "4c05626ccd70b1cab777c507b34f36ef27d41cbf";
      sha256 = "185mxjj3r9jhgylr3ai08i5br6xh7jifyqyxgsw9a0plq8qywcvl";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp";
  };

  nvim-cmp-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-treesitter";
    version = "2022-10-28";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "cmp-treesitter";
      rev = "b40178b780d547bcf131c684bc5fd41af17d05f2";
      sha256 = "076x4rfcvy81m28dpjaqcxrl3q9mhfz7qbwgkqsyndrasibsmlzr";
    };
    meta.homepage = "https://github.com/ray-x/cmp-treesitter";
  };

  nvim-cmp-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp";
    version = "2022-11-16";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "59224771f91b86d1de12570b4070fe4ad7cd1eeb";
      sha256 = "1m8xs7fznf4kk6d96f2fxgwd7i5scd04pfy2s4qsb5gzh7q2ka9j";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp";
  };

  nvim-cmp-lsp-document-symbol = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp-document-symbol";
    version = "2022-10-24";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-document-symbol";
      rev = "069a207be6a0327dcc62c957dbb38156b210733a";
      sha256 = "1gpw9zmx60y6zrxb7ncgmak7sgzg8j5fhd4hqx2qkkrq6qkh07d3";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol";
  };

  nvim-cmp-lsp-signature-help = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp-signature-help";
    version = "2022-10-14";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-signature-help";
      rev = "d2768cb1b83de649d57d967085fe73c5e01f8fd7";
      sha256 = "13imcdv0yws084z2x2lmdj17zy4ngf126i7djknnwp2jfkca1120";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help";
  };

  nvim-cmp-buffer = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-buffer";
    version = "2022-08-10";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "3022dbc9166796b644a841a02de8dd1cc1d311fa";
      sha256 = "1cwx8ky74633y0bmqmvq1lqzmphadnhzmhzkddl3hpb7rgn18vkl";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-buffer";
  };

  nvim-cmp-path = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-path";
    version = "2022-10-03";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "91ff86cd9c29299a64f968ebb45846c485725f23";
      sha256 = "18ixx14ibc7qrv32nj0ylxrx8w4ggg49l5vhcqd35hkp4n56j6mn";
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
    version = "2022-11-13";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "8bc9c4a34b223888b7ffbe45c4fe39a7bee5b74d";
      sha256 = "0rx8ncap1dfrgwkx1wsmhybr6cs1kdh0li5hssbhws2d6igij8zq";
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
    version = "2.0.3";
    src = fetchFromGitHub {
      owner = "phaazon";
      repo = "hop.nvim";
      rev = "v2.0.3";
      sha256 = "18akjbplhp27di5l0bi9yd2haysgvw8yv3yk6cgwbizmk6inb5ji";
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
    version = "0.6";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "v0.6";
      sha256 = "1gm5nmwfmkxb1a6vqbfyd1cm1vspa9d0gm09im9lv0m9mdf4pckv";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim";
  };

  trouble-nvim = buildVimPluginFrom2Nix {
    pname = "trouble-nvim";
    version = "1.0.0";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "trouble.nvim";
      rev = "v1.0.0";
      sha256 = "0p0ndaal7x7m286rw7plr2cjjck0vsq7x907v2mkfric0mdgklsk";
    };
    meta.homepage = "https://github.com/folke/trouble.nvim";
  };

  lir-nvim = buildVimPluginFrom2Nix {
    pname = "lir-nvim";
    version = "2022-09-14";
    src = fetchFromGitHub {
      owner = "tamago324";
      repo = "lir.nvim";
      rev = "c1aeb96fae55bb6cac3d01ce5123a843d7235396";
      sha256 = "03fia0m7w2q20m9jvm4wdm6w5bfh976fm0d7h4n055hbqgy73qf9";
    };
    meta.homepage = "https://github.com/tamago324/lir.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2023-01-30";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "9a0d3bf7b832818c042aaf30f692b081ddd58bd9";
      sha256 = "1xy4hs0pckzbxd249zwg2r0vi94fy9arb966nypw1dx4vxw8072z";
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
    version = "0.1.1";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "0.1.1";
      sha256 = "1w16rm50kav8fm3qvwxa58ag0njlg17j3rq140igyskr33cbd7ih";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "0.1.4";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "v0.1.4";
      sha256 = "1ig3fmj798axcv1694nna6bb97ij0rz0fm7jrfmqjs0p7sll10f9";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  nvim-dap = buildVimPluginFrom2Nix {
    pname = "nvim-dap";
    version = "0.4.0";
    src = fetchFromGitHub {
      owner = "mfussenegger";
      repo = "nvim-dap";
      rev = "0.4.0";
      sha256 = "16hrqqa6577lq51hcx048j8rwa6aqdb6dz9b94rv1ki0jy52cx00";
    };
    meta.homepage = "https://github.com/mfussenegger/nvim-dap";
  };

  lspkind-nvim = buildVimPluginFrom2Nix {
    pname = "lspkind-nvim";
    version = "2022-09-22";
    src = fetchFromGitHub {
      owner = "onsails";
      repo = "lspkind-nvim";
      rev = "c68b3a003483cf382428a43035079f78474cd11e";
      sha256 = "0qrfqajpbkb757vbcjz1g7v5rihsyhg1f1jxrbwg08dbxpw101av";
    };
    meta.homepage = "https://github.com/onsails/lspkind-nvim";
  };

  null-ls-nvim = buildVimPluginFrom2Nix {
    pname = "null-ls-nvim";
    version = "2023-01-23";
    src = fetchFromGitHub {
      owner = "jose-elias-alvarez";
      repo = "null-ls.nvim";
      rev = "7b2b28e207a1df4ebb13c7dc0bd83f69b5403d71";
      sha256 = "02ing7v31xk43161986b7np04d58cxkm19h00mq95gdbqy3gnaz8";
    };
    meta.homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2023-01-31";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "e00952111e94f95800a32eeedb057e7ad365960c";
      sha256 = "04jl2ay8qibqvisy4hhm0d579iwrglyw44r7k1a2lpnza4jvlsds";
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
    version = "2023-01-31";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "249d90a84df63f3ffff65fcc06a45d58415672de";
      sha256 = "01wm4gnwimsxgvdhjgn15d23nq6d1304jjvkr1wdjz7xk5g0xvaz";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };

  nvim-treesitter-context = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-context";
    version = "2023-01-06";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-context";
      rev = "cacee4828152dd3a83736169ae61bbcd29a3d213";
      sha256 = "0d9j5wz1fqk8ipf2x8vym0m3zpydslivwsnha8h1qz6yp6zyq5hc";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-context";
  };

  impatient-nvim = buildVimPluginFrom2Nix {
    pname = "impatient-nvim";
    version = "2022-12-28";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "impatient.nvim";
      rev = "c90e273f7b8c50a02f956c24ce4804a47f18162e";
      sha256 = "1cd1l55lax3938ym0kpwz0gpzmfi8rxq8rgl3l8vhq9frlaqyn53";
    };
    meta.homepage = "https://github.com/lewis6991/impatient.nvim";
  };

  dressing-nvim = buildVimPluginFrom2Nix {
    pname = "dressing-nvim";
    version = "2022-12-13";
    src = fetchFromGitHub {
      owner = "stevearc";
      repo = "dressing.nvim";
      rev = "4436d6f41e2f6b8ada57588acd1a9f8b3d21453c";
      sha256 = "1iwxqfqp3x09wz3rnvli3y80n38rw149cmjj9pmbkhiqgsm9p461";
    };
    meta.homepage = "https://github.com/stevearc/dressing.nvim";
  };

  which-key-nvim = buildVimPluginFrom2Nix {
    pname = "which-key-nvim";
    version = "1.1.0";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "which-key.nvim";
      rev = "v1.1.0";
      sha256 = "1r6zd308wqh730nafkif3pdmakb5c3h8m64lf3qjdwwzqfpx63rk";
    };
    meta.homepage = "https://github.com/folke/which-key.nvim";
  };
}
