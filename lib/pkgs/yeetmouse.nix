{ pkgs, stdenv, fetchFromGitHub, kernel ? pkgs.linuxPackages_latest.kernel, ... }:

stdenv.mkDerivation rec {
  pname = "yeetmouse";
  version = "ed39ee0457d330c751b689fe6e410acae8c40d4f";

  src = fetchFromGitHub {
    owner = "andyfilter";
    repo = "yeetmouse";
    rev = version;
    sha256 = "sha256-8cr4WYX09ej81tRJOfEytnPGj51voDQA9tEH91ukC+s=";
  };

  setSourceRoot = ''
    export sourceRoot=$(pwd)/source/driver
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(sourceRoot)"
  ];

  buildFlags = [ "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
  installTargets = [ "modules_install" ];
}
