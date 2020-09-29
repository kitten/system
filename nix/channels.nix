let
  inherit (import <nixpkgs> {}) fetchFromGitHub;

  darwin_src = fetchFromGitHub {
    owner = "LnL7";
    repo = "nix-darwin";
    rev = "828879f93084fdd5b12925acc016497d2410bdc4";
    sha256 = "137mdg921lw0mmir9ycx5v1166hmdn5z20brdcbdvyc1jd7m09sx";
  };

  home-manager_src = fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "e6f96b6aa3e99495f9f6f3488ecf78dd316e5bec";
    sha256 = "1xvxqw5cldlhcl7xsbw11n2s3x1h2vmbm1b9b69a641rzj3srg11";
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
