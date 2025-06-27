{ nixpkgs, darwin, home-manager, ... } @ inputs:

{
  mkSystem = { system, hostname, user ? "phil", modules ? [], overlays ? [] }: let
    inherit (lib.systems.elaborate { inherit system; }) isDarwin;

    homeDir = if isDarwin then "/Users/${user}" else "/home/${user}";
    rootDir = if isDarwin then "/var/root" else "/root";

    lib = (import nixpkgs { inherit overlays system; }).lib;

    age = {
      identityPaths = let
        identityPath = if isDarwin then "/usr/local/persistent/agenix" else "/var/lib/persistent/agenix";
      in [ identityPath ];
    };

    systemModules = modules ++ [
      ../machines/common.nix
      ../machines/${hostname}/configuration.nix
      ../modules/default.nix
      ({ ... }: {
        inherit age;

        nixpkgs = {
          inherit overlays;
          config.allowUnfree = true;
          hostPlatform = system;
        };

        networking.hostName = hostname;
        nix.extraOptions = "extra-experimental-features = nix-command flakes";
      })
    ];

    home = { ... }: {
      inherit age;

      manual.manpages.enable = false;
      xdg.enable = true;
      home = {
        stateVersion = "25.05";
        enableNixpkgsReleaseCheck = false;
      };

      imports = [
        inputs.agenix.homeManagerModules.default
        inputs.android-sdk.hmModules.android
        ../home/default.nix
        ../machines/${hostname}/home.nix
      ];
    };

    specialArgs = {
      inherit hostname user inputs;
      helpers = (import ./helpers.nix {
        inherit lib system;
      });
    };

  in if isDarwin then (
    darwin.lib.darwinSystem {
      inherit system specialArgs lib;
      modules = systemModules ++ [
        inputs.agenix.darwinModules.default
        home-manager.darwinModules.home-manager {
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${user}" = home;
        }
        ({ pkgs, ... }: {
          environment.shells = [pkgs.zsh];
          users.users."${user}".home = homeDir;
        })
      ];
    }
  ) else (
    nixpkgs.lib.nixosSystem {
      inherit system specialArgs lib;
      modules = systemModules ++ [
        inputs.yeetmouse.nixosModules.default
        inputs.agenix.nixosModules.default
        home-manager.nixosModules.home-manager {
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${user}" = home;
        }
        ({ pkgs, ... }: {
          users.defaultUserShell = pkgs.zsh;
          users.mutableUsers = false;
          users.users."${user}".home = homeDir;
        })
      ];
    }
  );
}
