let
  inherit (import <nixpkgs> {}) fetchFromGitHub;

  darwin_src = fetchFromGitHub {
    owner = "LnL7";
    repo = "nix-darwin";
    rev = "b8c286c82c6b47826a6c0377e7017052ad91353c";
    sha256 = "0cg2zv1avmqjymkynmgc2c5v9yk9wzl2kb66jrzc1kaqhz1xm544";
  };

  /* release-22.11 */
  home-manager_src = fetchFromGitHub {
    owner = "nix-community";
    repo = "home-manager";
    rev = "f9edbedaf015013eb35f8caacbe0c9666bbc16af";
    sha256 = "1cp2rpprcfl4mjsrsrpfg6278nf05a0mpl3m0snksvdalfmc5si5";
  };

  /* nixpkgs-23.05-darwin */
  nixpkgs_src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "8c5f01ab09866caa80e2876c9dfd922100984c7e";
    sha256 = "1i56m4mj55qqsdcbmzwvi9pcz3i9cjjd5wqlv5srs331kwbsdg00";
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
