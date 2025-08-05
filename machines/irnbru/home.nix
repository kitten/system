{ pkgs, ... }:

{
  modules = {
    development = {
      enable = true;
    };
    apps = {
      enable = true;
      ghostty.enable = true;
      ollama = {
        enable = true;
        package = with pkgs; stdenv.mkDerivation rec {
          pname = "ollama";
          version = "0.11.2";
          src = fetchurl {
            url = "https://github.com/ollama/ollama/releases/download/v${version}/ollama-darwin.tgz";
            hash = "sha256-gUKwOmZ6oViIEzozQx5FB5090Zs0q8nQTdRqjqa0t8I=";
          };
          sourceRoot = ".";
          dontBuild = true;
          dontConfigure = true;
          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin $out/lib/ollama
            ls -lah
            install -Dm755 ollama $out/bin/ollama
            cp -r *.so *.dylib $out/lib/ollama/
            runHook postInstall
          '';
        };
      };
    };
  };
}
