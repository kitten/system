{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    vim-repeat = {
      url = "github:tpope/vim-repeat";
      flake = false;
    };

    vim-fugitive = {
      url = "github:tpope/vim-fugitive";
      flake = false;
    };

    vim-golden-size = {
      url = "github:dm1try/golden_size";
      flake = false;
    };

    nvim-snippy = {
      url = "github:dcampos/nvim-snippy";
      flake = false;
    };

    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };

    nvim-cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };

    nvim-cmp-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };

    nvim-cmp-lsp-document-symbol = {
      url = "github:hrsh7th/cmp-nvim-lsp-document-symbol";
      flake = false;
    };

    nvim-cmp-lsp-signature-help = {
      url = "github:hrsh7th/cmp-nvim-lsp-signature-help";
      flake = false;
    };

    nvim-cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };

    nvim-cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };

    nvim-cmp-snippy = {
      url = "github:dcampos/cmp-snippy";
      flake = false;
    };

    nvim-cmp-cmdline = {
      url = "github:hrsh7th/cmp-cmdline";
      flake = false;
    };

    nvim-cmp-cmdline-history = {
      url = "github:dmitmel/cmp-cmdline-history";
      flake = false;
    };

    hardline-nvim = {
      url = "github:ojroques/nvim-hardline/9a6998ff2af04ee86cf87e710fd9daa279726bdc";
      flake = false;
    };

    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    trouble-nvim = {
      url = "github:folke/trouble.nvim/v2.3.0";
      flake = false;
    };

    lir-nvim = {
      url = "github:tamago324/lir.nvim";
      flake = false;
    };

    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };

    popup-nvim = {
      url = "github:nvim-lua/popup.nvim";
      flake = false;
    };

    telescope-nvim = {
      url = "github:nvim-telescope/telescope.nvim/0.1.1";
      flake = false;
    };

    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };

    nvim-dap = {
      url = "github:mfussenegger/nvim-dap/0.6.0";
      flake = false;
    };

    lspkind-nvim = {
      url = "github:onsails/lspkind-nvim";
      flake = false;
    };

    null-ls-nvim = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };

    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };

    nvim-treesitter-refactor = {
      url = "github:nvim-treesitter/nvim-treesitter-refactor";
      flake = false;
    };

    nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects";
      flake = false;
    };

    nvim-treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };

    dressing-nvim = {
      url = "github:stevearc/dressing.nvim";
      flake = false;
    };

    which-key-nvim = {
      url = "github:folke/which-key.nvim/v1.4.3";
      flake = false;
    };
  };

  outputs = { nixpkgs, flake-utils, ... } @ inputs: {
    overlays.default = self: super: let
      inherit (super.lib.attrsets) mapAttrs filterAttrs;
    in {
      nvim-plugins = mapAttrs (name: value:
        super.vimUtils.buildVimPluginFrom2Nix {
          pname = name;
          version = "flake";
          src = "${value.outPath}";
        }
      ) (
        filterAttrs
        (name: value: name != "nixpkgs" && name != "flake-utils")
        inputs
      );
    };
  };
}
