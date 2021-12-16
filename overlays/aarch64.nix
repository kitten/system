self: super:

let
  inherit (import ../nix/channels.nix) __nixPath nixPath;
  inherit (super.lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
  inherit (super) fetchFromGitHub;
  pkgsM1 = import <nixpkgs> { localSystem = "aarch64-darwin"; overlays = []; };
in

(if isDarwin then {
  inherit (pkgsM1) ffmpeg imagemagick tmux zsh starship gnupg nodejs-14_x nodejs-16_x postgresql_13;

  nodejs = pkgsM1.nodejs-16_x;

  neovim = (pkgsM1.wrapNeovim(
    pkgsM1.neovim-unwrapped.overrideAttrs(old: {
      version = "0.6.0-dev+560-g1fdbd29df";
      buildInputs = old.buildInputs ++ [ pkgsM1.tree-sitter ];
      cmakeFlags = old.cmakeFlags ++ [ "-DUSE_BUNDLED=OFF" ];
      src = fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "1fdbd29dfa6366f8346693d0bf67f4f782ab0f32";
        sha256 = "04x0ddisxiqwhd99pmrdj649i06hf50a3lzq9ii0xvkhsaarwbr4";
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
    version = "20211112-c47c7c6";
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
      rev = "c47c7c6d1fe9b0282c424e3dafe8d7b58f27c4d6";
      sha256 = "0pllcwk0wzyscrc8r2cjy4dvg3i73sjvvd49p758nyrvgxqvjyka";
      fetchSubmodules = true;
    };
    dontCargoCheck = true;
    cargoSha256 = null;
    cargoDeps = old.cargoDeps.overrideAttrs (super.lib.const {
      inherit src;
      name = "${name}-vendor.tar.gz";
      outputHash = "1wsm07ph0wh4sa7j2f91vrph1chw2c5hpa1kmpbhi2yq0wyir2fd";
    });
    OPENSSL_NO_VENDOR = 1;
    preBuild = ''
      export OPENSSL_DIR=${pkgsM1.lib.getDev pkgsM1.openssl}
      export OPENSSL_LIB_DIR=${pkgsM1.openssl.out}/lib
      export OPENSSL_INCLUDE_DIR=${pkgsM1.openssl.dev}/include
    '';
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

  yabai = (super.yabai.overrideAttrs(old: {
    version = "3.3.11-donaldguy.0";
    buildInputs = old.buildInputs ++ [ pkgsM1.darwin.apple_sdk.frameworks.SkyLight ];
    src = fetchFromGitHub {
      owner = "donaldguy";
      repo = old.pname;
      rev = "db3e811238850352cb63b6c8bc090a7157a4abcb";
      sha256 = "09lx8s19rrcydbjavfknkh945sdkl9qgic3sym4z731y79fb4sg3";
    };
  }));
} else {})
