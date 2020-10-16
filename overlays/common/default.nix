self: super:

let

  inherit (import ../../channels) __nixPath;
  inherit (super) callPackage fetchFromGitHub;
  inherit (super.lib) replaceStrings;

  mkPackage = args: pkg: callPackage pkg args;

in

rec {
  neovim = super.wrapNeovim(
    super.neovim-unwrapped.overrideAttrs(old: {
      src = super.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "0af18a6a4325d24bf4c386edb81c2f3776dab787";
        sha256 = "0ki16a12ga88xby9d70raqr7g5m3bf6ihl0dl1jp08wwp2wwxh3l";
      };
    })
  ) {};

  vimPlugins = super.vimPlugins // (import ./vim-plugins.nix) {
    inherit (super) fetchFromGitHub;
    inherit (super.vimUtils) buildVimPluginFrom2Nix;
  };
}
