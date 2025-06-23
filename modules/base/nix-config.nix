{ lib, pkgs, inputs, helpers, user, config, ... }:

with lib; mkMerge [
  {
    age.secrets."nix-access-tokens.conf".file = ./encrypt/nix-access-tokens.conf.age;

    nix = {
      package = pkgs.lix;
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
        # Use xdg spec for .nix-defexpr
        use-xdg-base-directories = true;
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
        allowed-users = [ "root" "@wheel" "${user}" ];
        extra-trusted-users = [ "${user}" ];
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
    system.stateVersion = 6;
  })
]
