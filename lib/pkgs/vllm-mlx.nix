self: pkgs @ {
  lib,
  python3Packages,
  fetchFromGitHub,
  ...
}:

let
  pythonPackages = python3Packages.overrideScope (pself: psuper: {
    accelerate = psuper.accelerate.overridePythonAttrs {
      doCheck = false;
    };
  });

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
