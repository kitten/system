let
  inherit (import <nixpkgs> {}) fetchFromGitHub;

  darwin_src = fetchFromGitHub {
    owner = "LnL7";
    repo = "nix-darwin";
    rev = "5af1aa51f63d734284bf6728a21d2c9c31eb7492";
    sha256 = "0izqpq424j4w2w9p3k8vi831k2g9cqvmlaz25pgdfrqmrs2i42fg";
  };

  /* release-21.11 */
  home-manager_src = fetchFromGitHub {
    owner = "nix-community";
    repo = "home-manager";
    rev = "d93d56ab8c1c6aa575854a79b9d2f69d491db7d0";
    sha256 = "1fi27zabvqlyc2ggg7wr01j813gs46rswg1i897h9hqkbgqsjkny";
  };

  /* nixpkgs-21.11-darwin */
  nixpkgs_src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "eabc38219184cc3e04a974fe31857d8e0eac098d";
    sha256 = "04ffwp2gzq0hhz7siskw6qh9ys8ragp7285vi1zh8xjksxn1msc5";
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
