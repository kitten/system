self: pkgs @ {
  stdenv,
  cmake,
  pkg-config,
  fetchFromGitHub,
  systemdLibs,
  ...
}:

stdenv.mkDerivation rec {
  pname = "systemd-transparent-udp-forwarderd";
  version = "0.0.1-add-activity-timeout-shutdown";
  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ systemdLibs ];
  src = fetchFromGitHub {
    owner = "cecton";
    repo = "systemd-transparent-udp-forwarderd";
    rev = "69072ef1271f013cefa91c239455d197f68d3f8e";
    sha256 = "sha256-c4pui1aHw35Jw1pjCBgLQTHrjt5nYI2IUD4FqkyEd/M=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 systemd-transparent-udp-forwarderd "$out/bin/$pname"
    runHook postInstall
  '';

  meta.mainProgram = pname;
}
