self: pkgs @ {
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  fixDarwinDylibNames,
  ...
}:

let
  pythonPackages = python3Packages.overrideScope (pself: psuper: {
    inherit mlx;
    accelerate = psuper.accelerate.overridePythonAttrs {
      doCheck = false;
    };
  });

  mlx-metal = pythonPackages.buildPythonPackage rec {
    pname = "mlx_metal";
    version = "0.30.5";
    format = "wheel";

    src = pythonPackages.fetchPypi {
      inherit pname version format;
      python = "py3";
      dist = "py3";
      platform = "macosx_15_0_arm64";
      hash = "sha256-nOCxaexwQ9RtY6ewTgSP3VEkahNMjufsy537jbnz9Gg=";
    };

    dontStrip = true;
    doCheck = false;
  };

  # See: https://github.com/aldur/dotfiles/blob/1b93ba9/nix/packages/mlx/default.nix
  mlx = pythonPackages.buildPythonPackage rec {
    pname = "mlx";
    version = "0.30.5";
    format = "wheel";

    src = pythonPackages.fetchPypi {
      inherit pname version format;
      python = "cp313";
      dist = "cp313";
      abi = "cp313";
      platform = "macosx_15_0_arm64";
      hash = "sha256-jiTUDoxYJ6JC17i6I3nI7OV3a3Fj4FzrehEOwWFYL5E=";
    };

    nativeBuildInputs = [ fixDarwinDylibNames ];
    dependencies = [ mlx-metal ];

    postInstall = ''
      libdir=${mlx-metal}/lib/python3.13/site-packages/mlx
      cp -r "$libdir/lib" "$out/lib/python3.13/site-packages/mlx/"
    '';

    postFixup = lib.optionalString stdenv.isDarwin ''
      libdir="$out/lib/python3.13/site-packages/mlx"

      if [ -f "$libdir/lib/libmlx.dylib" ]; then
        for so in "$libdir"/*.so; do
          if [ -f "$so" ] && [ "$so" != "$libdir/core.cpython-313-darwin.so" ]; then
            install_name_tool -add_rpath "$libdir/lib" "$so" 2>/dev/null || true
            install_name_tool -change @rpath/libmlx.dylib "$libdir/lib/libmlx.dylib" "$so" 2>/dev/null || true
          fi
        done
        exit 0
      fi

      echo "ERROR: libmlx.dylib not found after copying from mlx_metal"
      exit 1
    '';

    dontStrip = true;
    doCheck = false;
    pythonImportsCheck = [ "mlx.core" ];

    meta = {
      platforms = lib.platforms.darwin;
      broken = !stdenv.isDarwin || !stdenv.isAarch64;
    };
  };

  gradio = pythonPackages.gradio.overridePythonAttrs {
    pythonRelaxDeps = true;
    doCheck = false;
  };

  mlx-embeddings = pythonPackages.buildPythonPackage rec {
    pname = "mlx-embeddings";
    version = "0.0.5";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "Blaizzy";
      repo = "mlx-embeddings";
      rev = "v${version}";
      hash = "sha256-XI/cuF5CVesGG8JJXoxCh2GkMGDgSnrq5UUilWUh96w=";
    };

    build-system = with pythonPackages; [
      setuptools
      setuptools-scm
    ];

    dependencies = with pythonPackages; [
      mlx
      mlx-vlm
      transformers
      sentencepiece
      huggingface-hub
    ];

    pythonImportsCheck = [ "mlx_embeddings" ];
    doCheck = false;

    meta = with lib; {
      description = "MLX-based text embeddings";
      homepage = "https://github.com/Blaizzy/mlx-embeddings";
      license = licenses.mit;
      platforms = platforms.darwin;
    };
  };

in pythonPackages.buildPythonApplication rec {
  pname = "vllm-mlx";
  version = "0.2.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "waybarrios";
    repo = "vllm-mlx";
    rev = "v${version}";
    hash = "sha256-cLit8xU9ihEEj4siOAl+mPaETN68z3hpiOUGMHzUKgw=";
  };

  build-system = with pythonPackages; [
    setuptools
  ];

  dependencies = (with pythonPackages; [
    mlx
    mlx-lm
    mlx-vlm
    transformers
    tokenizers
    huggingface-hub
    fastapi
    uvicorn
    pillow
    numpy
    pyyaml
    opencv4
    psutil
    torchvision
    jsonschema
    tabulate
    tqdm
    requests
    mcp
    mlx-embeddings
    pytz
  ]) ++ [ gradio ];

  pythonImportsCheck = [ "vllm_mlx" ];

  meta = with lib; {
    description = "vLLM-compatible serving engine for Apple Silicon via MLX";
    homepage = "https://github.com/waybarrios/vllm-mlx";
    license = licenses.asl20;
    platforms = platforms.darwin;
    mainProgram = "vllm-mlx";
  };
}
