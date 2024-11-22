{
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
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

    yeetmouse = {
      url = "github:kitten/yeetmouse/next?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "git+ssh://git@github.com/ghostty-org/ghostty";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;
    inherit (import ./lib/system.nix inputs) mkSystem;
    eachSystem = lib.genAttrs ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
    overlays = [
      inputs.lix-module.overlays.lixFromNixpkgs
      inputs.nvim-plugins.overlays.default
      (self: super: {
        inherit (inputs.language-servers.packages.${self.system})
          typescript-language-server
          vscode-langservers-extracted;
        ghostty = inputs.ghostty.packages.${self.system}.default;
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

    nixosConfigurations."cola" = mkSystem {
      inherit overlays;
      system = "x86_64-linux";
      hostname = "cola";
    };

    nixosConfigurations."ramune" = mkSystem {
      inherit overlays;
      system = "aarch64-linux";
      hostname = "ramune";
    };

    packages = eachSystem (system: {
      inherit (inputs.agenix.packages.${system}) agenix;
      inherit (inputs.darwin.packages.${system}) darwin-rebuild;
    } // (import ./lib/pkgs inputs.nixpkgs.legacyPackages.${system}));

    apps = eachSystem (system: import ./lib/apps {
      inherit lib;
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    });
  };
}
