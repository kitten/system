{ lib, rustPlatform, openssh, git }:

rustPlatform.buildRustPackage {
  pname = "git-ssh-access";
  version = "0.1.0";
  src = lib.cleanSourceWith {
    src = ./.;
    filter = path: type: lib.cleanSourceFilter path type && baseNameOf path != "target";
  };
  cargoLock.lockFile = ./Cargo.lock;
  nativeCheckInputs = [ openssh git ];
  meta = {
    description = "Restricted Git access and SSH-agent-bound publication credentials";
    platforms = lib.platforms.unix;
    mainProgram = "git-ssh-access";
  };
}
