self: pkgs @ {
  stdenv,
  autoPatchelfHook,
  fetchFromGitHub,
  writeText,
  ...
}:

let
  makefile = writeText "Makefile" ''
    TARGETS = force-bind target-mkdir target-bind parent-socket-activate

    all: $(TARGETS)

    force-bind: main.c scm_functions.c
    	$(CC) $(CFLAGS) -o $@ $^

    parent-socket-activate: parent_soocket_activate.c
    	$(CC) $(CFLAGS) -o $@ $^

    target-mkdir: target_mkdir.c
    	$(CC) $(CFLAGS) -o $@ $^

    target-bind: target_bind.c
    	$(CC) $(CFLAGS) -o $@ $^

    .PHONY: all
  '';
in stdenv.mkDerivation rec {
  pname = "force-bind";
  version = "0.0.1-4867c53";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = with self; [ stdenv.cc.cc.lib stdenv.cc.libc.linuxHeaders ];
  buildPhase = "make";

  src = fetchFromGitHub {
    owner = "kitten";
    repo = "force-bind-seccomp";
    rev = "0df29fbbe20f5c191c3b76951af090ab60d533e8";
    sha256 = "sha256-SWdPacxJ2WmB+8b8uVpxrnlLuH3wAvFIDyfBclh0a/4=";
  };
  postPatch = ''
    cp ${makefile} Makefile;
  '';
  installPhase = ''
    runHook preInstall
    install -Dm755 force-bind "$out/bin/$pname"
    install -Dm755 target-bind "$out/bin/$pname-test-target-bind"
    install -Dm755 parent-socket-activate "$out/bin/$pname-test-socket-activate"
    runHook postInstall
  '';

  meta.mainProgram = pname;
}
