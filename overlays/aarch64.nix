self: super:

let
  inherit (import ../nix/channels.nix) __nixPath nixPath;
  inherit (super.lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
  inherit (super) fetchFromGitHub;
  pkgsM1 = import <nixpkgs> { localSystem = "aarch64-darwin"; overlays = []; };
in

(if isDarwin then {
  inherit (pkgsM1) ffmpeg imagemagick tmux zsh starship gnupg nodejs-14_x nodejs-16_x postgresql_13 rustup;

  nodejs = pkgsM1.nodejs-16_x;

  neovim = (pkgsM1.wrapNeovim(
    pkgsM1.neovim-unwrapped.overrideAttrs(old: {
      version = "0.7.0";
      buildInputs = old.buildInputs ++ [ pkgsM1.tree-sitter ];
      cmakeFlags = old.cmakeFlags ++ [ "-DUSE_BUNDLED=OFF" ];
      src = fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "333ba6569d833e22c0d291547d740d4bbfa3fdab";
        sha256 = "03wh090acplj5kgrw87m6dh0rh5f71bg60s75qmqcsfjjwg1m1kr";
      };
    })
  ) {}).overrideAttrs(old: {
    buildCommand = (''
      mkdir -p $out/home
      export HOME=$out/home
    '' + old.buildCommand);
  });

  wezterm = (pkgsM1.wezterm.overrideAttrs(old: rec {
    name = "wezterm";
    version = "20220408-101518-b908e2dd";
    buildInputs = (with pkgsM1; [
      openssl
      fontconfig
      zlib
      libiconv
    ]) ++ (with pkgsM1.darwin.apple_sdk.frameworks; [
      Cocoa
      CoreGraphics
      Foundation
      UserNotifications
    ]);
    postPatch = ''
      echo ${version} > .tag
    '';
    src = fetchFromGitHub {
      owner = "wez";
      repo = "wezterm";
      rev = "b908e2dd8cd27c613c8d76e9e6abc5245e500d7d";
      sha256 = "0rnc3f6s90q02inllaswvf4ki1ysfnnwaj2lbk83x0kax07siswj";
      fetchSubmodules = true;
    };
    dontCargoCheck = true;
    cargoSha256 = null;
    cargoDeps = old.cargoDeps.overrideAttrs (super.lib.const {
      inherit src;
      name = "${name}-vendor.tar.gz";
      outputHash = "02f37b79j0dgf1b98mxkqwg6nm8a207xlianhkplw9pjmngn6bga";
    });
    OPENSSL_NO_VENDOR = 1;
    preBuild = ''
      export OPENSSL_DIR=${pkgsM1.lib.getDev pkgsM1.openssl}
      export OPENSSL_LIB_DIR=${pkgsM1.openssl.out}/lib
      export OPENSSL_INCLUDE_DIR=${pkgsM1.openssl.dev}/include
    '';
    meta = super.lib.mkMerge [old.meta ({
      broken = false;
    })];
  }));

  kitty = (pkgsM1.kitty.overrideAttrs(old: rec {
    version = "0.23.1-cd7b4fc";
    buildInputs = old.buildInputs ++ (with pkgsM1.darwin.apple_sdk.frameworks; [ UserNotifications ]);
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

  skhd = (pkgsM1.skhd.overrideAttrs(old: {
    version = "0.3.5-b659b90";
    buildInputs = with pkgsM1.darwin.apple_sdk.frameworks; [ Carbon Cocoa ];
    src = fetchFromGitHub {
      owner = "koekeishiya";
      repo = old.pname;
      rev = "b659b90576cf88100b52ca6ab9270d84af7e579b";
      sha256 = "137v4xdpfjrzdp4vb5jkxa0ka8m30vdkqh701wki2l9xdmzgx7bg";
    };
  }));

  yabai = super.stdenv.mkDerivation rec {
    name = "yabai";
    version = "4.0.0";
    dontStrip = true;
    src = super.fetchzip {
      url = "https://github.com/koekeishiya/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
      sha256 = "1rwnf55pw9fvvv5pl22rvjif8z47f1l6ll06hfrj4y753b5i26h8";
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
    version = "2022-07-11";
    dontStrip = true;
    buildInputs = [ pkgsM1.gzip ];
    unpackPhase = ":";
    src = super.fetchurl {
      url = "https://github.com/rust-lang/rust-analyzer/releases/download/${version}/rust-analyzer-aarch64-apple-darwin.gz";
      sha256 = "0714nbjy12rq62n02bkcz20im680gawrqqfsc247hlpc6nwbkhwa";
    };
    installPhase = ''
      mkdir -p $out/bin
      gzip -dc $src > $out/bin/rust-analyzer
      chmod +x $out/bin/rust-analyzer
    '';
  };

} else {})
