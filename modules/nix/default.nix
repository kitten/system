{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;

    settings = {
      # save space
      auto-optimise-store = true;
      # flakes
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      # binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
      trusted-users = [ "root" "@wheel" ];
    };

    # auto collect old stores
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
      options = "--delete-older-than 14d";
    };
  };
}
