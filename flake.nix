{
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    apple-silicon = {
      url = "github:kitten/nixos-apple-silicon/edge";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
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
      url = "github:nix-community/home-manager";
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

    system-shell = {
      url = "github:kitten/system-shell";
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
      url = "github:AndyFilter/yeetmouse?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    android-sdk = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = inputs @ { self, ... }: let
    inherit (inputs.nixpkgs) lib;
    inherit (import ./lib/system.nix inputs) mkSystem;
    eachSystem = lib.genAttrs ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
    overlays = [
      self.overlays.default
      self.overlays.lix
      inputs.nvim-plugins.overlays.default
      inputs.android-sdk.overlays.default
      inputs.language-servers.overlays.default
      inputs.system-shell.overlays.default
      (self: super: {
        zen-browser = inputs.zen-browser.packages.${self.system}.beta;
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

    darwinConfigurations."irnbru" = mkSystem {
      inherit overlays;
      system = "aarch64-darwin";
      hostname = "irnbru";
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

    nixosConfigurations."sodacream" = mkSystem {
      inherit overlays;
      system = "aarch64-linux";
      hostname = "sodacream";
    };

    overlays = {
      default = import ./lib/pkgs;
      lix = import ./lib/lix-overlay.nix;
    };

    packages = eachSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ self.overlays.default self.overlays.lix ];
      };
    in {
      inherit (inputs.agenix.packages.${system}) agenix;
      inherit (inputs.darwin.packages.${system}) darwin-rebuild;
    } // {
      inherit (pkgs)
        steamworks-sdk-redist
        systemd-transparent-udp-forwarderd
        force-bind;
    });

    apps = eachSystem (system: import ./lib/apps {
      inherit lib;
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    });
  };
}
