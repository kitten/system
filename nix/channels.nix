let
  inherit (import <nixpkgs> {}) fetchFromGitHub;

  darwin_src = fetchFromGitHub {
    owner = "LnL7";
    repo = "nix-darwin";
    rev = "44da835ac40dab5fd231298b59d83487382d2fab";
    sha256 = "06nvl7d0zj2c02ax2v77580p8h0pjlrv1ah3qrl9c6lqadal4sf6";
  };

  home-manager_src = fetchFromGitHub {
    owner = "nix-community";
    repo = "home-manager";
    rev = "63f299b3347aea183fc5088e4d6c4a193b334a41";
    sha256 = "0iksjch94wfvyq0cgwv5wq52j0dc9cavm68wka3pahhdvjlxd3js";
  };

  /* nixpkgs-21.11-darwin */
  nixpkgs_src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "433b4266cdde34164a43d97bcc164015511bbe80";
    sha256 = "101s9qc2i5g42qvrdcxdxrryiiafyfwmjs1wmsqb5wyvf1i391na";
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
