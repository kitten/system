self: super:

let
  inherit (super) callPackage fetchzip fetchFromGitHub openssl python3;
  pkgs_x86 = import <nixpkgs> { localSystem = "x86_64-darwin"; overlays = []; };
in

rec {
  nodejs = self.nodejs-18_x;
  v8 = super.v8;

  vimPlugins = super.vimPlugins // (import ./vim-plugins.nix) {
    inherit (super) fetchFromGitHub;
    inherit (super.vimUtils) buildVimPluginFrom2Nix;
  };
}
