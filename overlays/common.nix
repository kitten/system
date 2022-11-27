self: super:

let
  inherit (super) callPackage fetchzip fetchFromGitHub openssl python3;
  pkgs_x86 = import <nixpkgs> { localSystem = "x86_64-darwin"; overlays = []; };
in

rec {
  nodejs = self.nodejs-18_x;
  v8 = super.v8;

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

  neovim = (super.wrapNeovim(
    super.neovim-unwrapped.overrideAttrs(old: {
      version = "0.9.0-nightly-3f47854";
      buildInputs = old.buildInputs ++ [ super.tree-sitter ] ++
        (with super.darwin.apple_sdk.frameworks; [ CoreServices ]);
      cmakeFlags = old.cmakeFlags ++ [ "-DUSE_BUNDLED=OFF" ];
      src = fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "3f478547cfec72b9d3eb53efde2df45d85c44c18";
        sha256 = "1w32scaknxhrdfwvs087rp9pjfzpcx639d6b0z6n9lksdx7aw7qq";
      };
    })
  ) {}).overrideAttrs(old: {
    buildCommand = (''
      mkdir -p $out/home
      export HOME=$out/home
    '' + old.buildCommand);
  });

  wezterm = super.stdenv.mkDerivation rec {
    name = "fastly";
    version = "2.0.0";

    src = fetchzip {
      url = "https://github.com/wez/wezterm/releases/download/20221119-145034-49b9839f/WezTerm-macos-20221119-145034-49b9839f.zip";
      sha256 = "1081dzqn1lff58yg7jhr83mrx07dqfrqaa7fqgjawykpk0zl89a9";
    };

    installPhase = ''
      mkdir -p $out/bin
      mkdir "$out/Applications"
      cp -r WezTerm.app "$out/Applications/WezTerm.app"
    '';
  };

  kitty = (super.kitty.overrideAttrs(old: rec {
    version = "0.23.1-cd7b4fc";
    buildInputs = old.buildInputs ++ (with super.darwin.apple_sdk.frameworks; [ UserNotifications ]);
    patches = [
      ../assets/patches/kitty/fix-user-notifications-setup.diff
    ];
    src = fetchFromGitHub {
      owner = "kovidgoyal";
      repo = "kitty";
      rev = "cd7b4fcd8e0cda6fa2d5ca18a308630bffc7bba9";
      sha256 = "0vpc17j8nxkq3w4kk05bfx4slv2k7mc29938pds6298fl59h676r";
    };
  }));

  skhd = (super.skhd.overrideAttrs(old: {
    version = "0.3.5-b659b90";
    buildInputs = with super.darwin.apple_sdk.frameworks; [ Carbon Cocoa ];
    src = fetchFromGitHub {
      owner = "koekeishiya";
      repo = old.pname;
      rev = "b659b90576cf88100b52ca6ab9270d84af7e579b";
      sha256 = "137v4xdpfjrzdp4vb5jkxa0ka8m30vdkqh701wki2l9xdmzgx7bg";
    };
  }));

  yabai = super.stdenv.mkDerivation rec {
    name = "yabai";
    version = "4.0.2";
    dontStrip = true;
    src = super.fetchzip {
      url = "https://github.com/koekeishiya/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
      sha256 = "1wmpsz3dfl3c6wb3psm86w72pjx33wlkcibpvs6yvlfymp612027";
    };
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/man/man1/
      cp ./bin/yabai $out/bin/yabai
      cp ./doc/yabai.1 $out/share/man/man1/yabai.1
    '';
  };

  rust-analyzer = super.stdenv.mkDerivation rec {
    name = "rust-analyzer";
    version = "2022-08-22";
    dontStrip = true;
    buildInputs = [ super.gzip ];
    unpackPhase = ":";
    src = super.fetchurl {
      url = "https://github.com/rust-lang/rust-analyzer/releases/download/${version}/rust-analyzer-aarch64-apple-darwin.gz";
      sha256 = "0qhc88j6apb343nq92ypispfizafagiwr0w895j2l04pi0j1q3vv";
    };
    installPhase = ''
      mkdir -p $out/bin
      gzip -dc $src > $out/bin/rust-analyzer
      chmod +x $out/bin/rust-analyzer
    '';
  };

  vimPlugins = super.vimPlugins // (import ./vim-plugins.nix) {
    inherit (super) fetchFromGitHub;
    inherit (super.vimUtils) buildVimPluginFrom2Nix;
  };
}
