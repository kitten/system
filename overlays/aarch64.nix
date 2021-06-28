self: super:

let
  inherit (import ../nix/channels.nix) __nixPath nixPath;
  inherit (super.lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
  inherit (super) fetchFromGitHub;
  pkgsM1 = import <nixpkgs> { localSystem = "aarch64-darwin"; overlays = []; };
in

(if isDarwin then {
  inherit (pkgsM1) ffmpeg imagemagick tmux zsh starship gnupg nodejs-14_x;

  nodejs = pkgsM1.nodejs-14_x;

  neovim = (pkgsM1.wrapNeovim(
    pkgsM1.neovim-unwrapped.overrideAttrs(old: {
      version = "0.5.0-bbd13aa";
      buildInputs = old.buildInputs ++ [ pkgsM1.tree-sitter ];
      cmakeFlags = old.cmakeFlags ++ [ "-DUSE_BUNDLED=OFF" ];
      src = fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "bbd13aadd7e55172d4c29c667f38949d8a19e1c0";
        sha256 = "1vq01z8zha1kk2fi98dg9432pdw1nh19b0g2hn3swyq9502hdydl";
      };
    })
  ) {}).overrideAttrs(old: {
    buildCommand = (''
      mkdir -p $out/home
      export HOME=$out/home
    '' + old.buildCommand);
  });

  kitty = (pkgsM1.kitty.overrideAttrs(old: rec {
    version = "0.21.2-90164df";
    buildInputs = old.buildInputs ++ (with pkgsM1.darwin.apple_sdk.frameworks; [ UserNotifications ]);
    patches = [
      ../assets/patches/kitty/fix-user-notifications-setup.diff
    ];
    src = fetchFromGitHub {
      owner = "kovidgoyal";
      repo = "kitty";
      rev = "90164dfee799ccf999b8b65d421efa48d0755593";
      sha256 = "sha256-/+OSVjC4++A4kaxEfI2kIgjXxL67lfoXCdH2PykLWxB=";
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

  yabai = (pkgsM1.yabai.overrideAttrs(old: {
    version = "3.3.10";
    buildInputs = old.buildInputs ++ [ pkgsM1.darwin.apple_sdk.frameworks.SkyLight ];
    src = fetchFromGitHub {
      owner = "koekeishiya";
      repo = old.pname;
      rev = "8777db43b8551e0bc4e5c55d1e15bcbed52501a1";
      sha256 = "1gd88s3a05qvvyjhk5wpw1crb7p1gik1gdxn7pv2vq1x7zyvzvph";
    };
  }));
} else {})
