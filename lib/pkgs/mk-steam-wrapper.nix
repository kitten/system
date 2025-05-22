self: pkgs @ {
  lib,
  box64,
  makeWrapper,
  pkgsCross,
  stdenv,
  ...
}:

with lib;
let
  useBox64 = stdenv.hostPlatform.isAarch64;

  defaultLibs = with self; [
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

  defaultNativeLibs = optionals useBox64 [ pkgsCross.gnu64.libgcc ];

  mkSteamWrapper = makeOverridable (
    {
      logLevel ? 0,
      env ? {},
      libs ? defaultLibs,
      nativeLibs ? defaultNativeLibs,
      extraWrapperArgs ? [],
    }: let
      runpaths = libs ++ optionals useBox64 nativeLibs;
      combinedEnv = optionalAttrs useBox64 {
        BOX64_LOG = logLevel;
        BOX64_DYNAREC_STRONGMEM = 0;
      } // env;
    in bin:
      stdenv.mkDerivation rec {
        name = "box64-wrapper";
        meta.mainProgram = name;

        dontUnpack = true;
        dontConfigure = true;
        dontBuild = true;

        nativeBuildInputs = [ makeWrapper ];
        buildInputs = runpaths;

        installPhase = let
          outBin = if useBox64 then "${box64}/bin/box64" else bin;
          targetBinFlag = if useBox64 then "--add-flags ${escapeShellArg bin}" else "";
        in ''
          runHook preInstall
          makeWrapper "${outBin}" "$out/bin/${name}" \
            ${concatStrings (mapAttrsToList (name: value: "--set ${name} '${toString value}' ") combinedEnv)} \
            --prefix LD_LIBRARY_PATH : ${makeLibraryPath runpaths} \
            ${targetBinFlag} \
            ${lib.strings.concatStringsSep " " extraWrapperArgs}
          runHook postInstall
        '';
      }
  );
in
  mkSteamWrapper { }
