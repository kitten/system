let
  inherit (import <nixpkgs> {}) fetchFromGitHub;

  darwin_src = fetchFromGitHub {
    owner = "LnL7";
    repo = "nix-darwin";
    rev = "87b9d090ad39b25b2400029c64825fc2a8868943";
    sha256 = "0c2naszb8xqi152m4b71vpi20cwacmxsx82ig8fgq61z9y05iiq2";
  };

  /* release-22.11 */
  home-manager_src = fetchFromGitHub {
    owner = "nix-community";
    repo = "home-manager";
    rev = "65c47ced082e3353113614f77b1bc18822dc731f";
    sha256 = "1fw01zfankc80rna9ch65p7bpg6fwcnvc0pmwvkpfazb7xq92108";
  };

  /* nixpkgs-22.11-darwin */
  nixpkgs_src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "ad6d0779992a795dccddac0ee6ef510859bc366b";
    sha256 = "0aqgqdxb47bah0f9m0cj5dkqj9vlph0p8mgivsf1mn6zh76cxh1k";
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
