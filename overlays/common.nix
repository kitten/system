self: super:

let
  inherit (super) callPackage fetchzip fetchFromGitHub openssl python3;
  inherit (import ../nix/channels.nix) __nixPath nixPath;

  pkgs = import <nixpkgs> {};

  neovim-nightly-overlay = (import (builtins.fetchTarball {
    url = https://github.com/mjlbach/neovim-nightly-overlay/archive/472c2233b80cf02c637bee5948fb4b671ae8c963.tar.gz;
  }) self super);
in

rec {
  nodejs = pkgs.nodejs-14_x;

  neovim = (super.wrapNeovim(
    neovim-nightly-overlay.neovim-nightly
  ) {}).overrideAttrs(old: {
    buildCommand = (''
      mkdir -p $out/home
      export HOME=$out/home
    '' + old.buildCommand);
  });

  flyctl = super.stdenv.mkDerivation {
    name = "flyctl";
    version = "0.0.211";

    src = fetchzip {
      url = "https://github.com/superfly/flyctl/releases/download/v0.0.211/flyctl_0.0.211_macOS_x86_64.tar.gz";
      sha256 = "1zvdjjj44ap79yyr6b9whq1s6f6p01h5hnyqj4bj66xi4b3993dy";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp flyctl $out/bin
    '';
  };

  yarn = (super.yarn.overrideAttrs(old: {
    version = "1.22.5";
    buildInputs = [ nodejs ];
    src = fetchzip {
      url = "https://github.com/yarnpkg/yarn/releases/download/v1.22.10/yarn-v1.22.10.tar.gz";
      sha256 = "0pdimll8lhsnqfafhdaxd6h6mgxhj1c7h56r111cmxhzw462y3mr";
    };
  }));

  nodePackages = (import ./nodePackages/node-packages.nix) {
    inherit (super) stdenv nix-gitignore lib fetchurl fetchgit;
    nodeEnv = import ./nodePackages/node-env.nix {
      inherit (super) stdenv lib python2 runCommand writeTextFile;
      inherit pkgs nodejs;
      libtool = null;
    };
  };

  vimPlugins = super.vimPlugins // (import ./vim-plugins.nix) {
    inherit (super) fetchFromGitHub;
    inherit (super.vimUtils) buildVimPluginFrom2Nix;
  };
}
