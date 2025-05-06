{
  stdenv,
  lib,
  fetchFromGitHub,
  unzip,
  ...
}: stdenv.mkDerivation rec {
  pname = "SF-Mono";
  version = "0";

  src = fetchFromGitHub {
    owner = "supercomputra";
    repo = "SF-Mono-Font";
    rev = "master";
    sha256 = "sha256-3wG3M4Qep7MYjktzX9u8d0iDWa17FSXYnObSoTG2I/o=";
  };

  nativeBuildInputs = [unzip];

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    cp *.otf $out/share/fonts/opentype/
  '';
}
