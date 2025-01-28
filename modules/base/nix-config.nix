{ lib, pkgs, inputs, helpers, config, ... }:

with lib; mkMerge [
  {
    age.secrets."nix-access-tokens.conf".file = ./encrypt/nix-access-tokens.conf.age;

    nix = {
      package = pkgs.nix;
      channel.enable = mkForce false;

      # make flake registry and nix path match flake inputs
      registry = mkForce (mapAttrs (_: flake: {inherit flake;}) inputs);
      nixPath = mapAttrsToList (n: _: "${n}=flake:${n}") inputs;

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        # binary caches
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        trusted-users = [ "root" "@wheel" ];
        # on Apple Silicon, Rosetta 2 allows for this
        extra-platforms = mkIf (helpers.system == "aarch64-darwin") [ helpers.system "x86_64-darwin" ];
      };

      optimise.automatic = true;

      # auto collect old stores
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      } // helpers.linuxAttrs {
        dates = "weekly";
      } // helpers.darwinAttrs {
        interval = { Weekday = 0; Hour = 0; Minute = 0; };
      };

      extraOptions = ''
        !include ${config.age.secrets."nix-access-tokens.conf".path}
      '';
    };
  }
  (helpers.darwinAttrs {
    system.stateVersion = 4;
    # Disable path verification of $NIX_PATH
    system.checks.verifyNixPath = false;
    # Auto upgrade nix package and the daemon service.
    services.nix-daemon.enable = true;
    # Auto-configure build users
    nix.configureBuildUsers = true;
    # Disable documentation until https://github.com/LnL7/nix-darwin/issues/217 is fixed.
    documentation.enable = false;
  })
]
