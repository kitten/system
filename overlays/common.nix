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
      url = "https://github.com/yarnpkg/yarn/releases/download/v1.22.10/yarn-v1.22.10.tar.gz";
      sha256 = "0pdimll8lhsnqfafhdaxd6h6mgxhj1c7h56r111cmxhzw462y3mr";
    };
  }));

  neovim = (super.wrapNeovim(
    super.neovim-unwrapped.overrideAttrs(old: {
      version = "0.5.0-nightly.a061d53";
      src = super.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "a061d53e18168130aad537a9e8012390834ff8c2";
        sha256 = "13brbz7lxks5jp09dnaiiwgxymacfnv5yhh0mcz1hksij9ibw938";
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
