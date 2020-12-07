let
  inherit (import <nixpkgs> {}) fetchFromGitHub;

  darwin_src = fetchFromGitHub {
    owner = "LnL7";
    repo = "nix-darwin";
    rev = "465539ad1d1ad458bd2179e5b10ad1d487f92e0a";
    sha256 = "1cg367fdnabd8vca6jjcssszn832q60xw4v7sdl3gwiyapisicw7";
  };

  home-manager_src = fetchFromGitHub {
    owner = "nix-community";
    repo = "home-manager";
    rev = "63f299b3347aea183fc5088e4d6c4a193b334a41";
    sha256 = "0iksjch94wfvyq0cgwv5wq52j0dc9cavm68wka3pahhdvjlxd3js";
  };

  /* nixos-20.09-small nixpkgs-20.09-darwin release-20.09 */
  nixpkgs_src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "99f8282a65821f148df596ba389606e732eaf99d";
    sha256 = "1mm4j1vjs875yzv03plng43ivny0qm09hxpn0if8g9vc849rwc2g";
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
