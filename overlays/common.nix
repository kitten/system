self: super:

let
  inherit (super) callPackage fetchzip fetchFromGitHub openssl python3;
  inherit (import ../nix/channels.nix) __nixPath nixPath;
  pkgs = import <nixpkgs> {};

  neovim-nightly-overlay = (import (builtins.fetchTarball {
    url = https://github.com/mjlbach/neovim-nightly-overlay/archive/master.tar.gz;
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

  yarn = (super.yarn.overrideAttrs(old: {
    version = "1.22.5";
    buildInputs = [ nodejs ];
    src = fetchzip {
      url = "https://github.com/yarnpkg/yarn/releases/download/v1.22.10/yarn-v1.22.10.tar.gz";
      sha256 = "0pdimll8lhsnqfafhdaxd6h6mgxhj1c7h56r111cmxhzw462y3mr";
    };
  }));

  nodePackages = (import ./nodePackages/node-packages.nix) {
    inherit (super) fetchurl fetchgit;
    nodeEnv = import ./nodePackages/node-env.nix {
      inherit (super) stdenv python2 utillinux runCommand writeTextFile;
      inherit nodejs;
      libtool = null;
    };
  };

  vimPlugins = super.vimPlugins // (import ./vim-plugins.nix) {
    inherit (super) fetchFromGitHub;
    inherit (super.vimUtils) buildVimPluginFrom2Nix;
  };
}
