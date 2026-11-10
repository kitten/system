{ lib, stdenvNoCC, fetchurl, unzip, makeWrapper }:

let
  sources = {
    aarch64-darwin = {
      arch = "arm64";
      hash = "sha256-g5Kk9Zyi13LEQIcfw8/yn7Sv0TT8UhBkiocq0I7MITY=";
    };
    x86_64-darwin = {
      arch = "x64";
      hash = "sha256-zt1jlbOQSOn4JTPBvGgFiXi/RZokSP66VWyJvdzu6D4=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in stdenvNoCC.mkDerivation rec {
  pname = "t3code-desktop-bin";
  version = "0.1.8";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-${source.arch}.zip";
    inherit (source) hash;
  };

  nativeBuildInputs = [ unzip makeWrapper ];
  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  # Preserve upstream's signed bundle, including its native helpers.
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications" "$out/bin"
    cp -R "T3 Code (Beta).app" "$out/Applications/"
    makeWrapper "$out/Applications/T3 Code (Beta).app/Contents/MacOS/T3 Code (Beta)" \
      "$out/bin/t3code-desktop"
    runHook postInstall
  '';

  meta = {
    description = "T3 Code desktop app from upstream binary releases";
    homepage = "https://t3.codes";
    license = lib.licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "t3code-desktop";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
