let
  inherit (import <nixpkgs> {}) fetchFromGitHub;

  darwin_src = fetchFromGitHub {
    owner = "LnL7";
    repo = "nix-darwin";
    rev = "6349b99bc2b96ded34d068a88c7c5ced406b7f7f";
    sha256 = "1y1vvpi73i4cp7ykcdbclkj02h9sp8ca3rvvgsmzjg0qrh01as40";
  };

  /* release-22.04 */
  home-manager_src = fetchFromGitHub {
    owner = "nix-community";
    repo = "home-manager";
    rev = "d93d56ab8c1c6aa575854a79b9d2f69d491db7d0";
    sha256 = "1fi27zabvqlyc2ggg7wr01j813gs46rswg1i897h9hqkbgqsjkny";
  };

  /* nixpkgs-22.11-darwin */
  nixpkgs_src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "8690906c4d80db5d85f52313a8487bf2e7b8d4c5";
    sha256 = "01vd4f2j8jdfclnhlbx4v8jxr7c7y80qb042aynx7rh3yh2z3kaw";
  };
in

rec {
  __nixPath = [
    { prefix = "binary-caches"; path = ./binary-caches; }
    { prefix = "darwin"; path = darwin_src; }
    { prefix = "darwin-config"; path = ../configuration.nix; }
    { prefix = "home-manager"; path = home-manager_src; }
    { prefix = "nixos"; path = nixpkgs_src; }
    { prefix = "nixos-config"; path = ../configuration.nix; }
    { prefix = "nixpkgs"; path = nixpkgs_src; }
    { prefix = "nixpkgs-overlays"; path = ../overlays/default.nix; }
  ];

  nixPath = map ({ prefix, path }: "${prefix}=${__replaceStrings [ "/mnt/" ] [ "/" ] (toString path)}") __nixPath;
}
