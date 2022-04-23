let
  inherit (import <nixpkgs> {}) fetchFromGitHub;

  darwin_src = fetchFromGitHub {
    owner = "LnL7";
    repo = "nix-darwin";
    rev = "2979028c51ba0ad7e2062dbdc1674be0f71092fc";
    sha256 = "16db6yna4nbsck6iagpa1ap6d966iw4viykiiqmn4b5il2xl70k1";
  };

  /* release-21.11 */
  home-manager_src = fetchFromGitHub {
    owner = "nix-community";
    repo = "home-manager";
    rev = "7244c6715cb8f741f3b3e1220a9279e97b2ed8f5";
    sha256 = "1v0gb46whw152y56flvarg5xq7gfrr7ifbqmpgbb2rsipnjhzz81";
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
