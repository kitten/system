{ lib, pkgs, ... } @ inputs:

with lib;
let
  inherit ((import ./steamworks.nix) inputs) steamworks-sdk-redist;
in {
  logLevel ? 0,
  env ? {},
  libs ? [],
  extraWrapperArgs ? [],
}: let
  box64Bin = "${pkgs.box64}/bin/box64";
  runpaths = with pkgs; [
    steamworks-sdk-redist
    glibc
    libxcrypt
    libGL
    libdrm
    mesa  # for libgbm
    udev
    libudev0-shim
    libva
    vulkan-loader
  ];
  combinedEnv = {
    BOX64_DYNAREC_STRONGMEM = 1;
    BOX64_DYNAREC_BIGBLOCK = 1;
    BOX64_DYNAREC_SAFEFLAGS = 1;
    BOX64_DYNAREC_FASTROUND = 1;
    BOX64_DYNAREC_FASTNAN = 1;
    BOX64_DYNAREC_X87DOUBLE = 0;
  } // env;
in pkgs.stdenv.mkDerivation rec {
  name = "box64-wrapped";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = runpaths ++ libs;

  installPhase = ''
    runHook preInstall
    makeWrapper "${box64Bin}" "$out/bin/box64" \
      ${concatStrings (mapAttrsToList (name: value: "--set ${name} '${toString value}' ") env)} \
      --set BOX64_LOG "${toString logLevel}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
      ${lib.strings.concatStringsSep " " extraWrapperArgs}
    runHook postInstall
  '';
}
