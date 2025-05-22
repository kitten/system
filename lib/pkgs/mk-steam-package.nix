self: pkgs @ {
  lib,
  stdenv,
  autoPatchelfHook,
  ...
}:

with lib;
let
  inherit (stdenv.hostPlatform) isAarch64;
in
{
  name,
  hash ? "",
  version,
  appId,
  depotId,
  manifestId,
  ...
} @ args: let
  derivationArgs = builtins.removeAttrs args [ "name" "appId" "depotId" "manifestId" "hash" ];
in
stdenv.mkDerivation (rec {
  pname = name;
  src = self.fetchSteam {
    inherit name appId depotId manifestId hash;
  };

  dontBuild = true;
  dontConfigure = true;
  dontFixup = isAarch64;

  nativeBuildInputs = optionals (!isAarch64) [ autoPatchelfHook ];
  appendRunpaths = with self; makeLibraryPath [
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv ./* $out
    chmod 755 -R $out

    runHook postInstall
  '';
} // derivationArgs)
