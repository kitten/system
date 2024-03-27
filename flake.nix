{
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        darwin.follows = "darwin";
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    language-servers = {
      url = "github:kitten/language-servers.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    nvim-plugins = {
      url = "github:kitten/system-nvim-plugins.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { nixos-hardware, ...} @ inputs: let
    inherit (import ./lib/system.nix inputs) mkSystem;
    overlays = [
      inputs.nvim-plugins.overlays.default
      (self: super: {
        inherit (inputs.language-servers.packages.${self.system})
          astro-language-server
          typescript-language-server
          vscode-langservers-extracted;
      })
    ];
  in {
    darwinConfigurations."sprite" = mkSystem {
      inherit overlays;
      system = "aarch64-darwin";
      hostname = "sprite";
    };

    darwinConfigurations."fanta" = mkSystem {
      inherit overlays;
      system = "aarch64-darwin";
      hostname = "fanta";
    };

    nixosConfigurations."pepper" = mkSystem {
      inherit overlays;
      system = "x86_64-linux";
      hostname = "pepper";
    };
  };
}
