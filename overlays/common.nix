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

  cloudflared = super.stdenv.mkDerivation rec {
    name = "cloudflared";
    version = "2023.1.0";

    src = fetchzip {
      url = "https://github.com/cloudflare/cloudflared/releases/download/${version}/cloudflared-darwin-amd64.tgz";
      sha256 = "sha256-J1rHhT2MaRHQJwfcPLyA7+c3YaT8C5JeXyPy0qvLH3E=";
    };

    installPhase = ''
      mkdir -p $out/bin
      cp cloudflared $out/bin
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

   wezterm = super.stdenv.mkDerivation rec {
    name = "wezterm";
    version = "20230408-112425-69ae8472";

    src = fetchzip {
      url = "https://github.com/wez/wezterm/releases/download/20230408-112425-69ae8472/WezTerm-macos-20230408-112425-69ae8472.zip";
      sha256 = "1ymfv28l3z0fckbl7sghlw6v546kp33fq165jgmr8yxg58jrrh16";
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
    version = "2023-05-29";
    dontStrip = true;
    buildInputs = [ super.gzip ];
    unpackPhase = ":";
    src = super.fetchurl {
      url = "https://github.com/rust-lang/rust-analyzer/releases/download/${version}/rust-analyzer-aarch64-apple-darwin.gz";
      sha256 = "sha256-hmEbBZLWBs3sJF7la7d1RG75yoGH10RdNDl+sxz+xGI=";
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
