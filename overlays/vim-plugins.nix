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

  nvim-compe = buildVimPluginFrom2Nix {
    pname = "nvim-compe";
    version = "2021-07-01";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-compe";
      rev = "077329e6bd1704d1acdff087ef1a73df23e92789";
      sha256 = "0spnybax3zqcac1by0785v5zh4gl07lpgq6ivnnx1wyhfky87jx3";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-compe";
  };

  hop-nvim = buildVimPluginFrom2Nix {
    pname = "hop-nvim";
    version = "2021-07-01";
    src = fetchFromGitHub {
      owner = "phaazon";
      repo = "hop.nvim";
      rev = "0e9d4b4585f8a37d6cccbe9dd5993900b96a595b";
      sha256 = "0gpah47azk1miybwm2aa6m3vm08683z85rgrjfywx76fnih9rs66";
    };
    meta.homepage = "https://github.com/phaazon/hop.nvim";
  };

  lualine-nvim = buildVimPluginFrom2Nix {
    pname = "lualine-nvim";
    version = "2021-05-27";
    src = fetchFromGitHub {
      owner = "hoob3rt";
      repo = "lualine.nvim";
      rev = "9726824f1dcc8907632bc7c32f9882f26340f815";
      sha256 = "0gmbv0pbswkxjd4qw7dq66gp3fj594di0pgkb47yh3b46id8vkyj";
    };
    meta.homepage = "https://github.com/hoob3rt/lualine.nvim";
  };

  defx-nvim = buildVimPluginFrom2Nix {
    pname = "defx-nvim";
    version = "2021-06-22";
    src = fetchFromGitHub {
      owner = "shougo";
      repo = "defx.nvim";
      rev = "b3353d8bc1f14553e18c68332dc65418977698d1";
      sha256 = "0cydx3qv217k72rvn3gx3wb3dv5y6bf4zgggz8s84w9kn451swxn";
    };
    meta.homepage = "https://github.com/Shougo/defx.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2021-06-19";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "268002fdba2f8f5a4e86574e3b9924ad6d42da20";
      sha256 = "07zskz9b5s4cainjqj431b2skzdrhnm8agydmjxmw13qjmwj0q7z";
    };
    meta.homepage = "https://github.com/nvim-lua/plenary.nvim";
  };

  popup-nvim = buildVimPluginFrom2Nix {
    pname = "popup-nvim";
    version = "2021-05-08";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "popup.nvim";
      rev = "5e3bece7b4b4905f4ec89bee74c09cfd8172a16a";
      sha256 = "1k6rz652fjkzhjd8ljr0l6vfispanrlpq0r4aya4qswzxni4rxhg";
    };
    meta.homepage = "https://github.com/nvim-lua/popup.nvim";
  };

  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-nvim";
    version = "2021-06-14";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "6ac5ee0854fe02d651cadf2fc97a2463ff92f322";
      sha256 = "1k2glya8cd000kzfvx5fif9fcqvcq1k2vrkwyzhfm4yngz7bxm1p";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2020-06-20";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "48e47b4d26e45977d27c06dc1bc116416ca9276d";
      sha256 = "1zf4sv91i3qkr9d8cbn9vzk2sc5bknjsjdhzvpf1zjr72bxx3q37";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2021-06-25";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "5e500cbc8816d5cec7ad21398f6be2fe608583e6";
      sha256 = "1fj7g7bwal9cz3fkvdn57xbbdln730qqmrbm80wbvs49dr2psjbk";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter";
  };

  nvim-treesitter-refactor = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-refactor";
    version = "2021-05-03";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-refactor";
      rev = "1a377fafa30920fa974e68da230161af36bf56fb";
      sha256 = "06vww83i73f4gyp3x0007qqdk06dd2i9v1v9dk12ky9d8r0pmxl6";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-refactor";
  };

  nvim-treesitter-textobjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textobjects";
    version = "2021-06-25";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "2e4eebd39cd89ec6ebb1a85fb6da831784503627";
      sha256 = "1q323lgr35nl5hla0gsayd74d9fh78yvf8hyyfm5j5rlq2knc2ip";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };
}
