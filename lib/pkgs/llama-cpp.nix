self: pkgs @ {
  lib,
  llama-cpp,
  fetchFromGitHub,
  ...
}:

with lib;
llama-cpp.overrideAttrs (finalAttrs: prevAttrs: rec {
  version = "8183";
  src = fetchFromGitHub {
    owner = "ggml-org";
    repo = "llama.cpp";
    tag = "b${version}";
    hash = "sha256-ElVxZ9iWg7fCGWy+ttsLlCESasLt5GrRAKpUjoKaOdg=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  npmDepsHash = "sha256-FKjoZTKm0ddoVdpxzYrRUmTiuafEfbKc4UD2fz2fb8A=";
})
