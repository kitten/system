pkgs @ {
  lib,
  bash,
  stdenv,
  coreutils,
  fetchFromGitHub,
  kernel ? pkgs.linuxPackages_latest.kernel,
  ...
}:

stdenv.mkDerivation rec {
  pname = "yeetmouse";
  version = "ed39ee0457d330c751b689fe6e410acae8c40d4f";

  src = fetchFromGitHub {
    owner = "andyfilter";
    repo = "yeetmouse";
    rev = version;
    sha256 = "sha256-8cr4WYX09ej81tRJOfEytnPGj51voDQA9tEH91ukC+s=";
  };

  setSourceRoot = "export sourceRoot=$(pwd)/source";
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ pkgs.makeWrapper ];
  buildInputs = [ pkgs.glfw3 ];

  makeFlags = kernel.makeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(sourceRoot)/driver"
  ];

  postUnpack = ''
    cp -r $src/gui $sourceRoot/gui
    chmod 755 -R $sourceRoot/gui
    substituteInPlace $sourceRoot/driver/util.c \
      --replace "#define NUM_USAGES 32" "#define NUM_USAGES 90"
  '';

  preBuild = ''
    cp $sourceRoot/driver/config.sample.h $sourceRoot/driver/config.h
  '';

  LD_LIBRARY_PATH = "/run/opengl-driver/lib:${lib.makeLibraryPath buildInputs}";

  postBuild = ''
    make "-j$NIX_BUILD_CORES" -C $sourceRoot/gui "M=$sourceRoot/gui" "LIBS=-lglfw -lGL"
  '';

  postInstall = ''
    install -Dm755 $sourceRoot/gui/YeetMouseGui $out/bin/yeetmouse
    install -D $src/install_files/udev/99-leetmouse.rules $out/lib/udev/rules.d/98-leetmouse.rules
    install -Dm755 $src/install_files/udev/leetmouse_bind $out/lib/udev/rules.d/leetmouse_bind
    substituteInPlace $out/lib/udev/rules.d/98-leetmouse.rules \
      --replace "PATH='/sbin:/bin:/usr/sbin:/usr/bin'" ""
    patchShebangs $out/lib/udev/rules.d/leetmouse_bind
    wrapProgram $out/lib/udev/rules.d/leetmouse_bind \
      --prefix PATH : ${lib.makeBinPath [ bash coreutils ]}
    substituteInPlace $out/lib/udev/rules.d/98-leetmouse.rules \
      --replace "leetmouse_bind" "$out/lib/udev/rules.d/leetmouse_bind"
  '';

  buildFlags = [ "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
  installTargets = [ "modules_install" ];
}
