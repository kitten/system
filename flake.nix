{
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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

    wezterm = {
      url = "github:wez/wezterm/main?dir=nix";
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

  outputs = inputs: let
    inherit (import ./lib/system.nix inputs) mkSystem;
    eachSystem = inputs.nixpkgs.lib.genAttrs ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
    eachDarwinSystem = inputs.nixpkgs.lib.genAttrs ["aarch64-darwin" "x86_64-darwin"];
    overlays = [
      inputs.nvim-plugins.overlays.default
      (self: super: {
        inherit (inputs.language-servers.packages.${self.system})
          typescript-language-server
          vscode-langservers-extracted;
        wezterm = (inputs.wezterm.packages.${self.system}).default;
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
    }) // eachDarwinSystem (system: {
      inherit (inputs.darwin.packages.${system}) darwin-rebuild;
    });
  };
}
