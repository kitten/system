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
    rev = "360e2af4f876e2580de12d477a6167ed756ab65e";
    sha256 = "1i3i9cpn6m3r07pgw4w3xinbqmxkm7pmnqjlz96x424ngbc21sg2";
  };

  nixpkgs_unstable_src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "a7f375d3354af159eab45896e012fb9e856b93cb";
    sha256 = "1kskrplv144vcnig6mpzwd3kpac3sy3ss6023h0i65lc1qp4hgrl";
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
