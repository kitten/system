{
  fetchFromGitHub,
  buildVimPluginFrom2Nix,
}:

{
  vim-repeat = buildVimPluginFrom2Nix {
    pname = "vim-fugitive";
    version = "2022-01-25";
    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-repeat";
      rev = "24afe922e6a05891756ecf331f39a1f6743d3d5a";
      sha256 = "0y18cy5wvkb4pv5qjsfndrpcvz0dg9v0r6ia8k9isp4agdmxkdzj";
    };
    meta.homepage = "https://github.com/tpope/vim-repeat";
  };

  vim-fugitive = buildVimPluginFrom2Nix {
    pname = "vim-fugitive";
    version = "2023-04-29";
    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-fugitive";
      rev = "5f0d280b517cacb16f59316659966c7ca5e2bea2";
      sha256 = "0qgxchrsydxznxwz3gwksqg3nal1ypmwi0ibpkf4whc62a8xxgl6";
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
    version = "2023-05-15";
    src = fetchFromGitHub {
      owner = "dcampos";
      repo = "nvim-snippy";
      rev = "7b50933b44ebefc85bf1734eadc4fcfcbbc781c7";
      sha256 = "0pgwr8c3qkrg5zjyy0i99yclh7s2fbinr2nkwi3w2i9i6q04jmcx";
    };
    meta.homepage = "https://github.com/dcampos/nvim-snippy";
  };

  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2023-05-30";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "fc0f694af1a742ada77e5b1c91ff405c746f4a26";
      sha256 = "1vmsa4vrx7nsrq2kzh8pyjfssfhb9b7xy7qqcyja4g0xp9z9z077";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp";
  };

  nvim-cmp-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-treesitter";
    version = "2022-04-06";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "cmp-treesitter";
      rev = "389eadd48c27aa6dc0e6b992644704f026802a2e";
      sha256 = "0kbxjpw7j90pgvwmx3cb47jkk01wx5q6fqr660llinqc1vmj1rsq";
    };
    meta.homepage = "https://github.com/ray-x/cmp-treesitter";
  };

  nvim-cmp-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp";
    version = "2023-02-06";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "0e6b2ed705ddcff9738ec4ea838141654f12eeef";
      sha256 = "0gpwwc3rhfckaava83hpl7pw4rspicblxs7hy3y57gb560ymq6hg";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp";
  };

  nvim-cmp-lsp-document-symbol = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp-document-symbol";
    version = "2023-04-01";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-document-symbol";
      rev = "f0f53f704c08ea501f9d222b23491b0d354644b0";
      sha256 = "1zcplbb2kkq3f9mmy6zfgscdiccqiwkjr4d91qqjxp80yi1v9z4j";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol";
  };

  nvim-cmp-lsp-signature-help = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp-signature-help";
    version = "2023-02-03";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-signature-help";
      rev = "3d8912ebeb56e5ae08ef0906e3a54de1c66b92f1";
      sha256 = "0bkviamzpkw6yv4cyqa9pqm1g2gsvzk87v8xc4574yf86jz5hg68";
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
    version = "2023-04-24";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "5af1bb7d722ef8a96658f01d6eb219c4cf746b32";
      sha256 = "02xpxdbjvic4l2s4fmhiy38igvvg0mdpi6hr49kvnibx1dyzhx5k";
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
    version = "2023-05-25";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "f868d82a36f7f7f5e110eb0a9659993984f59875";
      sha256 = "1pbrm7y6z1b96yy8v9chn69jfbznlzrkygp802cb4946snnb5dj7";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim";
  };

  trouble-nvim = buildVimPluginFrom2Nix {
    pname = "trouble-nvim";
    version = "2.3.0";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "trouble.nvim";
      rev = "v2.3.0";
      sha256 = "08yf7vkg4mp9v46w858bab6b23cf1idc2hizpqviipafdngcfa51";
    };
    meta.homepage = "https://github.com/folke/trouble.nvim";
  };

  lir-nvim = buildVimPluginFrom2Nix {
    pname = "lir-nvim";
    version = "2023-02-21";
    src = fetchFromGitHub {
      owner = "tamago324";
      repo = "lir.nvim";
      rev = "1aa871f20637eccc4e1e26b0fbcf9aafc9b6caf7";
      sha256 = "0vwlp8b4kj0201abq5rh470kf4lsk2pr1207qhjd2ay1wp69ywiq";
    };
    meta.homepage = "https://github.com/tamago324/lir.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2023-05-31";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "499e0743cf5e8075cd32af68baa3946a1c76adf1";
      sha256 = "0r9aw3a53vzq0rdyvq7pi99pqbmnww0dm146pbj2kd33rb34daz6";
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
    version = "2023-05-29";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "9166622781a39a829878d1fd24c174529d996838";
      sha256 = "1rms9dbiv1cmc8dwmsr3k8xsn8lcgqkiljfld1jx2yyj8l8xc19b";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  nvim-dap = buildVimPluginFrom2Nix {
    pname = "nvim-dap";
    version = "0.6.0";
    src = fetchFromGitHub {
      owner = "mfussenegger";
      repo = "nvim-dap";
      rev = "0.6.0";
      sha256 = "0h4vcdy7zrbrx29r2bw5nk01q1y983ffh59sl35rq5aa9xdwr4zf";
    };
    meta.homepage = "https://github.com/mfussenegger/nvim-dap";
  };

  lspkind-nvim = buildVimPluginFrom2Nix {
    pname = "lspkind-nvim";
    version = "2023-05-05";
    src = fetchFromGitHub {
      owner = "onsails";
      repo = "lspkind-nvim";
      rev = "57610d5ab560c073c465d6faf0c19f200cb67e6e";
      sha256 = "18lpp3ng52ylp8s79qc84b4dhmy7ymgis7rjp88zghv1kndrksjb";
    };
    meta.homepage = "https://github.com/onsails/lspkind-nvim";
  };

  null-ls-nvim = buildVimPluginFrom2Nix {
    pname = "null-ls-nvim";
    version = "2023-05-30";
    src = fetchFromGitHub {
      owner = "jose-elias-alvarez";
      repo = "null-ls.nvim";
      rev = "c89333e034a8daba654ebfcf9a4ec9f87765f01e";
      sha256 = "1kpyh1y5p0cazbvcm9cazkc93giqbbngm9zk1pf5qxrl18217cqh";
    };
    meta.homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2023-05-31";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "62146fe415193879290c523b54cb5072e1f5dbbc";
      sha256 = "0zqkhdcc8vr0kp4f1jr8m0zp02f694ba5z7a5s7ypik2jdfqhv3w";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter";
  };

  nvim-treesitter-refactor = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-refactor";
    version = "2023-04-04";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-refactor";
      rev = "65ad2eca822dfaec2a3603119ec3cc8826a7859e";
      sha256 = "14vg4iykl56ii4m5jrbrw95yjzkqn53vyqpqm82a5lmxgsha8d6b";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-refactor";
  };

  nvim-treesitter-textobjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textobjects";
    version = "2023-05-23";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "95b76b95eff25e1e64f363938cd853852355d70a";
      sha256 = "0j1mrq2djx5f7xvxdjj441skkh4dmjz8frd06951pnxdar3ljqbn";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };

  nvim-treesitter-context = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-context";
    version = "2023-05-31";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-context";
      rev = "2182556aab4524b4fa8d00031bf1228ea2e4a023";
      sha256 = "0xybwafqdq540nlvcdax48xa04d85blm19gndlg1zyrkhs7hbd7i";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-context";
  };

  dressing-nvim = buildVimPluginFrom2Nix {
    pname = "dressing-nvim";
    version = "2023-05-25";
    src = fetchFromGitHub {
      owner = "stevearc";
      repo = "dressing.nvim";
      rev = "f19cbd56f7f8cad212c58a7285d09c5d9c273896";
      sha256 = "1vp2shlqqmwj11wv3hz8zdk84pdgf6y9pjw0gcr7ikfn0ag0a8dx";
    };
    meta.homepage = "https://github.com/stevearc/dressing.nvim";
  };

  which-key-nvim = buildVimPluginFrom2Nix {
    pname = "which-key-nvim";
    version = "1.4.3";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "which-key.nvim";
      rev = "v1.4.3";
      sha256 = "1ajzsxlpqzwi4ajq1rh134712gdsk6v2y8za16bfvbi20mf3v6n0";
    };
    meta.homepage = "https://github.com/folke/which-key.nvim";
  };
}
