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
    version = "2021-11-11";
    src = fetchFromGitHub {
      owner = "dcampos";
      repo = "nvim-snippy";
      rev = "6ef9366e8f25282e054c79d86cd234d8f37ab4fe";
      sha256 = "1ws8hrklj453jifcq2j82gsfpkl8sal75bwi63q5ci5wqx6n9jh2";
    };
    meta.homepage = "https://github.com/dcampos/nvim-snippy";
  };

  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2021-08-31";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "674d2b1389615f8c9c9366d4d01d0c26c0ba939d";
      sha256 = "1dknmk7y9wsqw8sm0slhvhd8nhjnn97icm52s447pzfrb0xq4h71";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp";
  };

  nvim-cmp-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp";
    version = "2021-10-17";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "accbe6d97548d8d3471c04d512d36fa61d0e4be8";
      sha256 = "1dqx6yrd60x9ncjnpja87wv5zgnij7qmzbyh5xfyslk67c0i6mwm";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-nvim-lsp";
  };

  nvim-cmp-buffer = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-buffer";
    version = "2021-09-02";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "5dde5430757696be4169ad409210cf5088554ed6";
      sha256 = "0fdywbv4b0z1kjnkx9vxzvc4cvjyp9mnyv4xi14zndwjgf1gmcwl";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-buffer";
  };

  nvim-cmp-path = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-path";
    version = "2021-10-27";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "97661b00232a2fe145fe48e295875bc3299ed1f7";
      sha256 = "160jidd951qz1byjhbmd7ijp6hd37bdxbpg5wmzhprihwwpm628j";
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
    version = "2021-10-29";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "a5cf11a8cd3a99294bc78e609d7c9323fef88831";
      sha256 = "10b0smfww4g6kajy5sjrxknid3lc43kfviaq94rvq05r322kldh4";
    };
    meta.homepage = "https://github.com/hrsh7th/cmp-cmdline";
  };

  hop-nvim = buildVimPluginFrom2Nix {
    pname = "hop-nvim";
    version = "2021-10-25";
    src = fetchFromGitHub {
      owner = "phaazon";
      repo = "hop.nvim";
      rev = "59bc934bdfa7d8fa8dab61b3cf0f667586c69fe1";
      sha256 = "0mkapij49vlaav2kzpbgbip3g30x2xivamabl4fbvp6p29nr3v1f";
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
    version = "2021-11-04";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "61a81b0c003de3e12555a5626d66fb6a060d8aca";
      sha256 = "0ya0vgwlmy2mpkgqhz0lyxh19iwilm5vwvk4c9ygsxwq3561vfcw";
    };
    meta.homepage = "https://github.com/lewis6991/gitsigns.nvim";
  };

  trouble-nvim = buildVimPluginFrom2Nix {
    pname = "trouble-nvim";
    version = "2021-10-25";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "trouble.nvim";
      rev = "756f09de113a775ab16ba6d26c090616b40a999d";
      sha256 = "016aivnqq9lh33in5611phhl7h6sz9xqgmiaq5swk4pk7vyl4nqq";
    };
    meta.homepage = "https://github.com/folke/trouble.nvim";
  };

  lir-nvim = buildVimPluginFrom2Nix {
    pname = "lir-nvim";
    version = "2021-11-03";
    src = fetchFromGitHub {
      owner = "tamago324";
      repo = "lir.nvim";
      rev = "e340f4ee25c74aaa6d67d84a5f48024a8f6422a0";
      sha256 = "08wbfpdirmdjnj7l7kd008iwcp466skflb3rr3rzqshmqfv7vqfk";
    };
    meta.homepage = "https://github.com/tamago324/lir.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2021-10-29";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "96e821e8001c21bc904d3c15aa96a70c11462c5f";
      sha256 = "0y05pwc4kbjqgj1zjjhvmrll3d53wz55zgqavxd4bvj2gwhvnd2k";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim";
  };

  popup-nvim = buildVimPluginFrom2Nix {
    pname = "popup-nvim";
    version = "2021-08-09";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "popup.nvim";
      rev = "f91d80973f80025d4ed00380f2e06c669dfda49d";
      sha256 = "1pp1d6kbx8yn4cg2zs8rynvvpa8y89ryr8rial9csg26v2z22z95";
    };
    meta.homepage = "https://github.com/nvim-lua/popup.nvim";
  };

  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-nvim";
    version = "2021-10-31";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "0caec3d6e4d3c3c71339eb18a9aae7ed0f24badc";
      sha256 = "0jq65g2769csgi4saw5d6mmy141wl1bkplv59jqmzhalz0k5dqr4";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2020-11-01";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "8cd75c8fdfe6f5122b077fc990bb1fa9fbcbb50c";
      sha256 = "1hcl770lmzxcgwim1fksy7qfcznyh08bdylmijvlc3f8xdh07rgm";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  lspkind-nvim = buildVimPluginFrom2Nix {
    pname = "lspkind-nvim";
    version = "2020-10-25";
    src = fetchFromGitHub {
      owner = "onsails";
      repo = "lspkind-nvim";
      rev = "1557ce5b3b8e497c1cb1d0b9d967a873136b0c23";
      sha256 = "0qrfrwd7mz311hjmpkjfjg1d2dkar675vflizpj0p09b5dp8zkbv";
    };
    meta.homepage = "https://github.com/onsails/lspkind-nvim";
  };

  null-ls-nvim = buildVimPluginFrom2Nix {
    pname = "null-ls-nvim";
    version = "2020-11-04";
    src = fetchFromGitHub {
      owner = "jose-elias-alvarez";
      repo = "null-ls.nvim";
      rev = "64b269b51c7490660dcb2008f59ae260f2cdbbe4";
      sha256 = "1vp5y8cd3ljhshg2hrisbgxxb1zz5xqqxldngv3ll98pd98f9yjy";
    };
    meta.homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2021-11-01";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "6d08b25f0e1e054a06241e2897a45fffe9fe6f8d";
      sha256 = "09p2msrhqvb3501hjw3vlpzmkp1a66jgjyy9bj7xg4zd83j72lza";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter";
  };

  nvim-treesitter-refactor = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-refactor";
    version = "2021-07-04";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-refactor";
      rev = "505e58a8b04596a073b326157490706ee63c3b81";
      sha256 = "0z42rpnig6iq73d3mjfgadvqa03k02f4c89j5dp9dhpnrjja8nha";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-refactor";
  };

  nvim-treesitter-textobjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textobjects";
    version = "2021-10-19";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "ba9be1b0369d77c76ad09ea6f7048d55c3905e75";
      sha256 = "0qdnx62shnsblhhxwwz7m48ib4390l1vrlpkkwd4bk07lhcafdm3";
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
    version = "2021-11-03";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "impatient.nvim";
      rev = "f4a45e4be49ce417ef2e15e34861994603e3deab";
      sha256 = "0q034irf77rlk07fd350zbg73p4daj7bakklk0q0rf3z31npwx8l";
    };
    meta.homepage = "https://github.com/lewis6991/impatient.nvim";
  };
}
