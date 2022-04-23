self: super:

let
  inherit (super) callPackage fetchzip fetchFromGitHub openssl python3;
in

rec {
  nodejs = self.nodejs-16_x;

  flyctl = super.stdenv.mkDerivation rec {
    name = "flyctl";
    version = "0.0.281";

    src = fetchzip {
      url = "https://github.com/superfly/flyctl/releases/download/v${version}/flyctl_${version}_macOS_x86_64.tar.gz";
      sha256 = "1wr6r4x9za3nlkgxg95wpij117ghgn9h4327fid24kgjcngk83x2";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp flyctl $out/bin
    '';
  };

  fastly = super.stdenv.mkDerivation rec {
    name = "fastly";
    version = "2.0.0";

    src = fetchzip {
      url = "https://github.com/fastly/cli/releases/download/v${version}/fastly_v${version}_darwin-amd64.tar.gz";
      sha256 = "01hlc8nh98d9ikpkmxcm9h2ygkhgfh4f9vr18lwb698dwx8vx3rd";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp fastly $out/bin
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
      inherit (super) stdenv lib python2 runCommand writeTextFile writeShellScript;
      nodejs = self.nodejs-14_x;
      pkgs = super;
      libtool = null;
    };
  };

  vimPlugins = super.vimPlugins // (import ./vim-plugins.nix) {
    inherit (super) fetchFromGitHub;
    inherit (super.vimUtils) buildVimPluginFrom2Nix;
  };
}
