self: pkgs @ {
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

with lib;
buildGoModule rec {
  pname = "pinentry-touchid";
  version = "v0.0.4";
  vendorHash = "sha256-v3JtUk94/javwhtUsPUFV9EwFfaixZpb4AqKpCEaZp4=";
  proxyVendor = true;

  doCheck = false;
  doInstallCheck = true;

  src = fetchFromGitHub {
    owner = "lujstn";
    repo = "pinentry-touchid";
    rev = "v0.0.4";
    sha256 = "sha256-2+AuUbyA1CZQROjX/Wlcx+OVsvOQgli5oPjAEdKB1Gk=";
  };

  subPackages = [ "." ];
  buildInputs = with pkgs; [ makeBinaryWrapper ];
  nativeBuildInputs = with pkgs; [ pinentry_mac ];
  ldflags = [ "-s" "-w" "-X main.version=${version}" "-X main.commit=${src.rev}" ];

  patchPhase = ''
    substituteInPlace go.mod \
      --replace-fail "=> ./go-assuan" "=> $src/go-assuan"
  '';

  postInstall = ''
    wrapProgram $out/bin/pinentry-touchid \
      --prefix PATH : ${pkgs.pinentry_mac}/bin
  '';
}
