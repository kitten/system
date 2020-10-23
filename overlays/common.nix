self: super:

let
  inherit (import ../nix/channels.nix) __nixPath;
  inherit (super) callPackage fetchzip fetchFromGitHub openssl python3;

  unstable = import <nixpkgs-unstable> {};
in

rec {
  nodejs = unstable.nodejs-14_x;

  yarn = (super.yarn.overrideAttrs(old: {
    version = "1.22.5";
    buildInputs = [ nodejs ];
    src = fetchzip {
      url = "https://github.com/yarnpkg/yarn/releases/download/v1.22.5/yarn-v1.22.5.tar.gz";
      sha256 = "1yb1pb80jhw6mx1r28hf7zd54dygmnrf30r3fz7kn9nrgdpl5in8";
    };
  }));

  neovim = (super.wrapNeovim(
    super.neovim-unwrapped.overrideAttrs(old: {
      version = "0.5.0-nightly";
      src = super.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "0af18a6a4325d24bf4c386edb81c2f3776dab787";
        sha256 = "0ki16a12ga88xby9d70raqr7g5m3bf6ihl0dl1jp08wwp2wwxh3l";
      };
    })
  ) {}).overrideAttrs(old: {
    buildCommand = (''
      mkdir -p $out/home
      export HOME=$out/home
    '' + old.buildCommand);
  });

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
