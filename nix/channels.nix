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
    rev = "826418fc35e4cd6e85a88edd389cb249a7aa9671";
    sha256 = "11kixdima3a1in55r4i3fvg0cya3b0v3142ny7gxdyi8xxxdlvn0";
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
