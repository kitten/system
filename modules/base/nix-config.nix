{ pkgs, nixpkgs, helpers, config, ... }:

{
  age.secrets."nix-access-tokens.conf".file = ./encrypt/nix-access-tokens.conf.age;

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;

    # provide for nix-shell and run
    nixPath = [ "nixpkgs=${nixpkgs.outPath}" ];

    settings = {
      # save space
      auto-optimise-store = true;
      # flakes
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
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
    };

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
} // helpers.darwinAttrs {
  system.stateVersion = 4;
  # Disable path verification of $NIX_PATH
  system.checks.verifyNixPath = false;
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # Auto-configure build users
  nix.configureBuildUsers = true;
  # Disable documentation until https://github.com/LnL7/nix-darwin/issues/217 is fixed.
  documentation.enable = false;
}
