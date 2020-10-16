self: super:

let

  inherit (import ../../channels) __nixPath;
  inherit (super) callPackage fetchFromGitHub;
  inherit (super.lib) replaceStrings;

  mkPackage = args: pkg: callPackage pkg args;

in

rec {
  vimPlugins = super.vimPlugins // (import ./vim-plugins.nix) {
    inherit (super) fetchFromGitHub;
    inherit (super.vimUtils) buildVimPluginFrom2Nix;
  };
}
