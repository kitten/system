{ lib, config, helpers, pkgs, ... }:

with lib;
let
  cfg = config.modules.apps;
  isDarwin = pkgs.stdenv.isDarwin;
  pkg = cfg.vllm.package;

  command = let
    executable = getExe pkg;
    serveArgs = [ executable "serve" cfg.vllm.model ];
  in serveArgs
    ++ [ "--port" (toString cfg.vllm.port) ]
    ++ optionals (cfg.vllm.host != null) [ "--host" cfg.vllm.host ]
    ++ optionals (cfg.vllm.apiKey != null) [ "--api-key" cfg.vllm.apiKey ]
    ++ optionals cfg.vllm.continuousBatching [ "--continuous-batching" ]
    ++ optionals cfg.vllm.usePagedCache [ "--use-paged-cache" ]
    ++ optionals (cfg.vllm.embeddingModel != null) [
        "--embedding-model"
        "${cfg.vllm.embeddingModel}"
      ]
    ++ optionals (cfg.vllm.defaultTemperature != null) [
        "--default-temperature"
        (toString cfg.vllm.defaultTemperature)
      ]
    ++ optionals (cfg.vllm.defaultTopP != null) [
        "--default-top-p"
        (toString cfg.vllm.defaultTopP)
      ]
    ++ optionals (cfg.vllm.toolcallParser != null) [
        "--enable-auto-tool-choice"
        "--tool-call-parser"
        "${cfg.vllm.toolcallParser}"
      ]
    ++ optionals (cfg.vllm.reasoningParser != null) [
        "--reasoning-parser"
        "${cfg.vllm.reasoningParser}"
      ]
    ++ cfg.vllm.extraArgs;
in {
  options.modules.apps.vllm = {
    enable = mkOption {
      default = false;
      description = "Whether to enable vLLM serving.";
      type = types.bool;
    };

    model = mkOption {
      description = "HuggingFace model ID to serve.";
      example = "mlx-community/Llama-3.2-3B-Instruct-4bit";
      type = types.str;
    };

    embeddingModel = mkOption {
      description = "Preloads an embedding model at startup (vllm-mlx)";
      example = "mlx-community/embeddinggemma-300m-6bit";
      type = types.nullOr types.str;
    };

    port = mkOption {
      default = 8000;
      description = "Port to serve on.";
      type = types.int;
    };

    host = mkOption {
      default = null;
      description = "Bind address.";
      type = types.nullOr types.str;
    };

    apiKey = mkOption {
      default = null;
      description = "Optional API key for the server.";
      type = types.nullOr types.str;
    };

    toolcallParser = mkOption {
      default = null;
      description = "Select the tool call parser for the model";
      type = types.nullOr (types.enum [
        "auto"
        "mistral"
        "qwen"
        "qwen3_coder"
        "llama"
        "hermes"
        "deepseek"
        "kimi"
        "granite"
        "nemotron"
        "xlam"
        "fnctionary"
        "glm47"
      ]);
    };

    reasoningParser = mkOption {
      default = "auto";
      description = "Select the tool call parser for the model";
      type = types.nullOr (types.enum [
        "qwen3"
        "deepseek_r1"
        "harmony"
      ]);
    };

    defaultTemperature = mkOption {
      default = null;
      description = "Overrides default model temperature (vllm-mlx)";
      type = types.nullOr types.float;
    };

    defaultTopP = mkOption {
      default = null;
      description = "Overrides default model top_p (vllm-mlx).";
      type = types.nullOr types.float;
    };

    continuousBatching = mkOption {
      default = false;
      description = "Enable continuous batching (vllm-mlx).";
      type = types.bool;
    };

    usePagedCache = mkOption {
      default = false;
      description = "Enable paged KV cache for memory efficiency (experimental; vllm-mlx).";
      type = types.bool;
    };

    extraArgs = mkOption {
      default = [];
      description = "Additional CLI arguments passed to the serve command.";
      type = types.listOf types.str;
    };

    package = mkOption {
      default = if isDarwin then pkgs.vllm-mlx else pkgs.vllm;
      type = types.package;
    };
  };

  config = mkIf (cfg.enable && cfg.vllm.enable) (mkMerge [
    (helpers.mkIfLinux {
      systemd.user.services.vllm = {
        Unit = {
          Description = "vLLM inference server";
          Documentation = "https://docs.vllm.ai";
        };
        Install.WantedBy = [ "default.target" ];
        Service = {
          ExecStart = escapeShellArgs command;
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    })

    (helpers.mkIfDarwin {
      launchd.agents.vllm = {
        enable = true;
        config = {
          ProcessType = "Background";
          ProgramArguments = command;
          KeepAlive = {
            Crashed = true;
            SuccessfulExit = false;
          };
        };
      };
    })
  ]);
}
