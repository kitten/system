self: pkgs @ {
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

with lib;
buildGoModule rec {
  pname = "pinentry-touchid";
  version = "v0.0.5";
  vendorHash = "sha256-3NeKIdsZ7uQQmVXDZ6zUQ0QMF4uxFcUDEOHbPSqoqOg=";
  proxyVendor = true;

  doCheck = false;
  doInstallCheck = true;

  src = fetchFromGitHub {
    owner = "kitten";
    repo = "pinentry-touchid";
    rev = "07322ff7e6509a575ce282aeb3b47db74a142a18";
    sha256 = "sha256-anSdpuUbB1VIIaU28kIqLjsdIEAgHxgzSf0g68MK2as=";
  };

  subPackages = [ "." ];
  buildInputs = with pkgs; [ makeBinaryWrapper ];
  nativeBuildInputs = with pkgs; [ pinentry_mac writableTmpDirAsHomeHook ];
  ldflags = [ "-s" "-w" "-X main.version=${version}" "-X main.commit=${src.rev}" ];

  patchPhase = ''
    substituteInPlace go.mod \
      --replace-fail "=> ./go-assuan" "=> $src/go-assuan" \
      --replace-fail "=> ./go-touchid" "=> $src/go-touchid"
  '';

  postInstall = ''
    wrapProgram $out/bin/pinentry-touchid \
      --prefix PATH : ${pkgs.pinentry_mac}/bin
  '';
}
