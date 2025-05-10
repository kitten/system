{
  stdenv,
  lib,
  fetchFromGitHub,
  unzip,
  ...
}: stdenv.mkDerivation rec {
  pname = "SF-Pro";
  version = "0";

  src = fetchFromGitHub {
    owner = "sahibjotsaggu";
    repo = "San-Francisco-Pro-Fonts";
    rev = "master";
    sha256 = "sha256-mAXExj8n8gFHq19HfGy4UOJYKVGPYgarGd/04kUIqX4=";
  };

  nativeBuildInputs = [unzip];

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    mkdir -p $out/share/fonts/truetype
    cp *.otf $out/share/fonts/opentype
    cp *.ttf $out/share/fonts/truetype
  '';
}
