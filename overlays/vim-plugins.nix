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
    version = "2022-08-20";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "828768631bf224a1a63771aefd09c1a072b6fe84";
      sha256 = "00dg06kl18wx6lanqis7h4ghcb3x96b1vsi2f0g8qidnl2jgg5af";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-cmp";
  };

  nvim-cmp-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-treesitter";
    version = "2022-06-09";
    src = fetchFromGitHub {
      owner = "ray-x";
      repo = "cmp-treesitter";
      rev = "c2886bbb09ef6daf996a258db29546cc1e7c12a7";
      sha256 = "1ar6d6pqybn4vqynbh18mc7fy1ybv0s9mi1r2j1nfcmgvh4wsvwk";
    };
    meta.homepage = "https://github.com/ray-x/cmp-treesitter";
  };

  nvim-cmp-lsp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp-lsp";
    version = "2022-05-16";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "affe808a5c56b71630f17aa7c38e15c59fd648a8";
      sha256 = "1v88bw8ri8w4s8yn7jw5anyiwyw8swwzrjf843zqzai18kh9mlnp";
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
    version = "2022-08-20";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp-signature-help";
      rev = "3dd40097196bdffe5f868d5dddcc0aa146ae41eb";
      sha256 = "0kfa0pw5yx961inirqwi0fjvgdbmsgw16703mw2w9km8313x17zw";
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
    version = "2022-07-26";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "447c87cdd6e6d6a1d2488b1d43108bfa217f56e1";
      sha256 = "0nmxwfn0gp70z26w9x03dk2myx9bbjxqw7zywzvdm28lgr43dwhv";
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
    version = "2022-08-05";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "9c0e331fe78cab7ede1c051c065ee2fc3cf9432e";
      sha256 = "0aadafmcbf23pw6swwfmbj4hcp4gawshz2ddhzagxflw398c0n9x";
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
    version = "2022-07-31";
    src = fetchFromGitHub {
      owner = "phaazon";
      repo = "hop.nvim";
      rev = "2a1b686aad85a3c241f8cd8fd42eb09c7de5ed79";
      sha256 = "1f8p8cxi74kgqs20knx7yq1bd7m30va1dqpsy5dqdzsazr50fymc";
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
    version = "2022-08-22";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "gitsigns.nvim";
      rev = "1e107c91c0c5e3ae72c37df8ffdd50f87fb3ebfa";
      sha256 = "0qg2y796mkkisyab6br4p0d6blx8ispglpphpdlmf14hp9si56bp";
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
    version = "2022-08-17";
    src = fetchFromGitHub {
      owner = "tamago324";
      repo = "lir.nvim";
      rev = "aecaa3fed11c4e19d869bb1e31f6ea4ef845578c";
      sha256 = "1cqp18v4l7r9w1bfdnxgsrlc80n71rxppx6zd2ac6gvvl5x6ig4g";
    };
    meta.homepage = "https://github.com/tamago324/lir.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2022-08-01";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "31807eef4ed574854b8a53ae40ea3292033a78ea";
      sha256 = "1vkyqrk0shpc076rq1s7rwldmcmw2k96hcpifligrsplr170kkhv";
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
    version = "2022-08-19";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "28dc08f614f45d37ad90f170935f1f4e12559aeb";
      sha256 = "1vmwp62aizvda3jmvi3j5rw8ffyfr6xk15adfqpj9gkgzw5lmh56";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2022-08-22";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "70af1bf414d7f9926fc883a008246db8a544f69c";
      sha256 = "0wkdqwlvq905i7jbvsyh5amv77vbhbl5xzhy4z1plbyv9zrywzcx";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  nvim-dap = buildVimPluginFrom2Nix {
    pname = "nvim-dap";
    version = "2022-06-10";
    src = fetchFromGitHub {
      owner = "mfussenegger";
      repo = "nvim-dap";
      rev = "014ebd53612cfd42ac8c131e6cec7c194572f21d";
      sha256 = "0qp15ihgwxamnly9ng6qmf051rz6yjg86p00dz39ffy02f8fvr60";
    };
    meta.homepage = "https://github.com/mfussenegger/nvim-dap";
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
    version = "2022-08-18";
    src = fetchFromGitHub {
      owner = "jose-elias-alvarez";
      repo = "null-ls.nvim";
      rev = "9d1f8dc1c8984e30efd8406aceba53dfadeaadbd";
      sha256 = "14ix8d2w8s7k4qai8vi7q47g14kxv0ba09r62lhabbqnd4fl9qyx";
    };
    meta.homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2022-08-22";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "09b13e9edb80d3890aa8f7dbebfdb21e34430212";
      sha256 = "1c17j81crh238xykmimdnlfm45lgah4iaw7c5rhf759d0xpn1c6v";
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
    version = "2022-08-21";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "ed60534707c99afc5ef5884fabd8bdada2c46527";
      sha256 = "0wydxbr9kxcqzj1ksz4a5qdybs8654pybqzcgy59c6kbzi59j43n";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };

  nvim-treesitter-context = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-context";
    version = "2022-08-05";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-context";
      rev = "8e88b67d0dc386d6ba1b3d09c206f19a50bc0625";
      sha256 = "1h74h4a69mxyc40nmg4mkaw6gja4hf6mvhrrh3vbh92lfb6k49sc";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-context";
  };

  impatient-nvim = buildVimPluginFrom2Nix {
    pname = "impatient-nvim";
    version = "2022-08-19";
    src = fetchFromGitHub {
      owner = "lewis6991";
      repo = "impatient.nvim";
      rev = "b842e16ecc1a700f62adb9802f8355b99b52a5a6";
      sha256 = "1q4ym3n98l3njs8qhiabvxc576xr7a5riykfcw6mh6vjkgs26jyd";
    };
    meta.homepage = "https://github.com/lewis6991/impatient.nvim";
  };

  dressing-nvim = buildVimPluginFrom2Nix {
    pname = "dressing-nvim";
    version = "2022-07-31";
    src = fetchFromGitHub {
      owner = "stevearc";
      repo = "dressing.nvim";
      rev = "d886a1bb0b43a81af58e0331fedbe8b02ac414fa";
      sha256 = "1cd11p19hi6jcmirahnmz8cp6962wm9rpjjypvffihj1j8wgl23p";
    };
    meta.homepage = "https://github.com/stevearc/dressing.nvim";
  };

  which-key-nvim = buildVimPluginFrom2Nix {
    pname = "which-key-nvim";
    version = "2022-05-04";
    src = fetchFromGitHub {
      owner = "folke";
      repo = "which-key.nvim";
      rev = "bd4411a2ed4dd8bb69c125e339d837028a6eea71";
      sha256 = "0vf685xgdb967wmvffk1pfrvbhg1jkvzp1kb7r0vs90mg8gpv1aj";
    };
    meta.homepage = "https://github.com/folke/which-key.nvim";
  };
}
