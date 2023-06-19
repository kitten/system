{ agenix, nixpkgs, darwin, home-manager, ... } @ inputs:

let
  inherit (nixpkgs) lib;
in {
  mkSystem = { system, hostname, user ? "phil", overlays }: let
    inherit (lib.systems.elaborate { inherit system; }) isDarwin;

    lib = (import nixpkgs { inherit overlays system; }).lib;

    age = {
      identityPaths = ["/var/lib/persistent/agenix"];
    };

    modules = [
      ../machines/common.nix
      ../machines/${hostname}/configuration.nix
      ../modules/default.nix
      ({ config, ... }: {
        inherit age;

        nixpkgs = {
          inherit overlays;
          config.allowUnfree = true;
        };

        networking.hostName = hostname;
        nix.extraOptions = "extra-experimental-features = nix-command flakes";
      })
    ];

    home = { ... }: {
      inherit age;

      manual.manpages.enable = false;
      home.stateVersion = "23.05";
      xdg.enable = true;

      imports = [
        agenix.homeManagerModules.default
        ../home/default.nix
        ../machines/${hostname}/home.nix
      ];
    };

    specialArgs = inputs // {
      inherit hostname user;
    };

  in if isDarwin then (
    darwin.lib.darwinSystem {
      inherit system lib;
      inputs = specialArgs;
      modules = modules ++ [
        agenix.darwinModules.default
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${user}" = home;
        }
        ({ pkgs, ... }: {
          environment.shells = [pkgs.zsh];
          users.users."${user}".home = "/Users/${user}";
        })
      ];
    }
  ) else (
    nixpkgs.lib.nixosSystem {
      inherit system specialArgs lib;
      modules = modules ++ [
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${user}" = home;
        }
        ({ pkgs, ... }: {
          users.defaultUserShell = pkgs.zsh;
          users.users."${user}".home = "/home/${user}";
        })
      ];
    }
  );
}
