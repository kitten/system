self: super:

let
  inherit (import ../nix/channels.nix) __nixPath nixPath;
  inherit (super.lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
  pkgsM1 = import <nixpkgs> { localSystem = "aarch64-darwin"; overlays = []; };
in

(if isDarwin then rec {
  ffmpeg = pkgsM1.ffmpeg;
  tmux = pkgsM1.tmux;
  nodejs-14_x = pkgsM1.nodejs-14_x;
  nodejs = nodejs-14_x;

  skhd = (pkgsM1.skhd.overrideAttrs(old: {
    version = "0.3.5-b659b90";
    buildInputs = with pkgsM1.darwin.apple_sdk.frameworks; [ Carbon Cocoa ];
    src = super.fetchFromGitHub {
      owner = "koekeishiya";
      repo = old.pname;
      rev = "b659b90576cf88100b52ca6ab9270d84af7e579b";
      sha256 = "137v4xdpfjrzdp4vb5jkxa0ka8m30vdkqh701wki2l9xdmzgx7bg";
    };
  }));

  yabai = (pkgsM1.yabai.overrideAttrs(old: {
    version = "3.3.10";
    buildInputs = old.buildInputs ++ [ pkgsM1.darwin.apple_sdk.frameworks.SkyLight ];
    src = super.fetchFromGitHub {
      owner = "koekeishiya";
      repo = old.pname;
      rev = "8777db43b8551e0bc4e5c55d1e15bcbed52501a1";
      sha256 = "1gd88s3a05qvvyjhk5wpw1crb7p1gik1gdxn7pv2vq1x7zyvzvph";
    };
  }));
} else {})
