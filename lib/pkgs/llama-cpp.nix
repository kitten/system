self: pkgs @ {
  lib,
  llama-cpp,
  fetchFromGitHub,
  ...
}:

with lib;
llama-cpp.overrideAttrs (old: rec {
  version = "8183";
  src = fetchFromGitHub {
    owner = "ggml-org";
    repo = "llama.cpp";
    rev = "b${version}";
    hash = "sha256-Cmma3SwcGiJJ87nCXUMJvB56La8+BSAu4YiuOxxQrWA=";
  };
})
