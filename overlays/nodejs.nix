{ lib, stdenv, fetchurl, gnutar, ... }:

let
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux isDarwin;
  nodejs-base = (import <nixpkgs> {}).nodejs-14_x;
in if isDarwin
  then stdenv.mkDerivation {
    name = "nodejs";
    version = "15.10.0";
    buildInputs = [ gnutar ];
    phases = [ "installPhase" ];

    srcs = [
      (fetchurl {
        url = "https://registry.npmjs.org/node-darwin-arm64/-/node-darwin-arm64-15.10.0.tgz";
        sha256 = "072db06k8bmxhqrbq5jjwl8m7gswrxcy3lw6qrgzy33hhmz1f6n6";
      })
      (fetchurl {
        url = "https://nodejs.org/dist/v15.10.0/node-v15.10.0-darwin-x64.tar.gz";
        sha256 = "1gj6sngzkh5ymsnczy6wypjr5abh158r6d9icpws8ff5bbfgik25";
      })
    ];

    meta = nodejs-base.meta;

    installPhase = ''
      for src in $srcs; do tar -xzf $src; done
      mkdir -p $out
      cp -R package/bin package/include package/lib package/share $out
      cp -R node-v15.10.0-darwin-x64/lib/node_modules $out/lib
      ln -s $out/lib/node_modules/npm/bin/npm-cli.js $out/bin/npm
      ln -s $out/lib/node_modules/npm/bin/npx-cli.js $out/bin/npx
    '';
  } else nodejs-base
