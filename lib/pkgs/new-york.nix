{
  stdenv,
  lib,
  fetchFromGitHub,
  unzip,
  ...
}: stdenv.mkDerivation rec {
  pname = "New-York";
  version = "0";

  src = fetchFromGitHub {
    owner = "yell0wsuit";
    repo = "New-York-fonts";
    rev = "master";
    sha256 = "sha256-0uuzr64KxDEMtkLizvGeHTXDBAMLe4j5iXGaJPfDdmg=";
  };

  nativeBuildInputs = [unzip];

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    cp *.otf $out/share/fonts/opentype/
  '';
}
