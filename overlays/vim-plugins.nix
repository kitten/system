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
    version = "2021-08-31";
    src = fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-compe";
      rev = "efd9f425383ec57756a74c60a6e85d190b110ed7";
      sha256 = "0vqmpgrvgn0923dadf9y1clxpaxf56brscsx31l96v2qghwac7m8";
    };
    meta.homepage = "https://github.com/hrsh7th/nvim-compe";
  };

  hop-nvim = buildVimPluginFrom2Nix {
    pname = "hop-nvim";
    version = "2021-07-14";
    src = fetchFromGitHub {
      owner = "phaazon";
      repo = "hop.nvim";
      rev = "9c849dac4b8efe6ad30aabec995dabfb5b251046";
      sha256 = "0z0ddrqhpirjdck9j0dmaxx0ra5hlcll0iawqb0078xg181bhnwh";
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
    version = "2021-08-18";
    src = fetchFromGitHub {
      owner = "shougo";
      repo = "defx.nvim";
      rev = "7e506d4b8cea834ef7e61a1f694540c5da418a25";
      sha256 = "16lg72l4zixhmd7pf8aliw3gwz2m25z90h8phmjj3d93w2g4q8zd";
    };
    meta.homepage = "https://github.com/Shougo/defx.nvim";
  };

  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2021-09-01";
    src = fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "06266e7bf675ba9af887fb6d1661b289fdd9bcf4";
      sha256 = "02c1y9ygzq8fmcgy7l4khpb141v2fww3gbl8vf0ds2f70zgglxs4";
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
    version = "2021-09-05";
    src = fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "5fc94cdd784ee1e4d79c850102b1035b58b5e435";
      sha256 = "1i8p3l4srmx8clyxmslim32gs0nwwfk298w574scy41w06y90jr2";
    };
    meta.homepage = "https://github.com/nvim-telescope/telescope.nvim";
  };

  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2020-09-05";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "cbd7c91530d62a72bf4a5a5a1aac384883077d81";
      sha256 = "0v10ai0061x4wb67igzrbvs7x2w7mky3vj3cxpvyymz2bw8isp26";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig";
  };

  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2021-09-03";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "8c105dedec9c6671697b5e68cd96d34a726db76d";
      sha256 = "0aiscb0jwr79zn8j28s5gpyvycch0kvs92hs8iywgdjcymnlj7ij";
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
    version = "2021-09-03";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter-textobjects";
      rev = "4cf4feaa893fc1e379d49942bc3d94034f5c9f61";
      sha256 = "1lp2nxscqvl4ay3pz3yj76wak2arnvrr098ml06ah261rd7548ai";
    };
    meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
  };
}
