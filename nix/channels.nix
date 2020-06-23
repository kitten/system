let
  inherit (import <nixpkgs> {}) fetchFromGitHub;

  darwin_src = fetchFromGitHub {
    owner = "LnL7";
    repo = "nix-darwin";
    rev = "47fe6db9c9cd22c4ba57df3281f98f454880bea7";
    sha256 = "198lxy1q7z6cmlyxd0rigrabjab4i49w2dk3xqm3bs4y0s0qimwy";
  };

  home-manager_src = fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "1f174f668109765183f96b43d56ee24ab02c1c05";
    sha256 = "06ba3nxkzva9q6dxzymyy62x75kf1qf7y8x711jwjravgda14bsq";
  };

  nixpkgs_src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "13c15f26d44cf7f54197891a6f0c78ce8149b037";
    sha256 = "0f2zc0wia9nx6i1mn1s7wd7xx7iqxb8l6mpx7nd0iazkkafwcgls";
  };

  nixpkgs_unstable_src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "801b645b2a327d4a7322226e854c2b1476000d6a";
    sha256 = "0mbfykklwj298m24l19i1m7wpfakqd1pg1z73vwml5jqp13xx0rk";
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
    { prefix = "nixpkgs-unstable"; path = nixpkgs_unstable_src; }
  ];

  nixPath = map ({ prefix, path }: "${prefix}=${__replaceStrings [ "/mnt/" ] [ "/" ] (toString path)}") __nixPath;
}
