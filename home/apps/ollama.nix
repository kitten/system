{ lib, config, helpers, pkgs, ... }:

with lib;
let
  cfg = config.modules.apps;
  ollama = cfg.ollama.package;
  ollamaArgs = [
    "${ollama}/bin/ollama"
    "serve"
  ];

  toEnvironmentCfg = vars: mapAttrsToList (k: v: "${k}=${escapeShellArg v}") vars;

  env = {
    OLLAMA_HOST = cfg.ollama.host;
    OLLAMA_FLASH_ATTENTION = if cfg.ollama.flashAttention then "1" else "0";
    OLLAMA_SCHED_SPREAD = if cfg.ollama.schedSpread then "1" else "0";
    OLLAMA_INTEL_GPU = if cfg.ollama.intelGpu then "1" else "0";
    OLLAMA_KV_CACHE_TYPE = cfg.ollama.kvCacheType;
    OLLAMA_CONTEXT_LENGTH = toString cfg.ollama.defaultContextLength;
    OLLAMA_MAX_LOADED_MODELS = toString cfg.ollama.maxLoadedModels;
  };
in {
  options.modules.apps.ollama = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Ollama.";
      type = types.bool;
    };

    enableServer = mkOption {
      default = true;
      description = "Whether to enable Ollama's server.";
      type = types.bool;
    };

    package = mkOption {
      default = pkgs.ollama;
      type = types.package;
    };

    host = mkOption {
      default = "http://0.0.0.0:11434";
      description = "Determines the host and port to listen on";
      type = types.str;
    };

    maxLoadedModels = mkOption {
      default = 3;
      type = types.int;
    };

    defaultContextLength = mkOption {
      default = 32768;
      type = types.int;
    };

    flashAttention = mkOption {
      default = true;
      description = ''
        Enables experimental flash attention feature.
        Effect: Activates an experimental optimization for attention mechanisms.
        Scenario: Can potentially improve performance on compatible hardware but may introduce instability.
      '';
      type = types.bool;
    };

    kvCacheType = mkOption {
      default = "q8_0";
      type = types.enum [ "f16" "q8_0" "q4_0" ];
      description = ''
        Determines the K/V cache quantization type
        Effect: Activates quantization of the K/V cache reducing memory usage with flash attention.
        Scenario: Can lead to reduced VRAM usage at the cost of accuracy.
        Models with a higher Grouped Query Attention (GQA) count (e.g. Qwen 2) will see a larger negative impact.
      '';
    };

    schedSpread = mkOption {
      default = false;
      description = ''
        Allows scheduling models across all GPUs.
        Effect: Enables multi-GPU usage for model inference.
        Scenario: Beneficial in high-performance computing environments with multiple GPUs to maximize hardware utilization.
      '';
      type = types.bool;
    };

    intelGpu = mkOption {
      default = false;
      description = ''
        Enables experimental Intel GPU detection.
        Effect: Allows usage of Intel GPUs for model inference.
        Scenario: Useful for organizations leveraging Intel GPU hardware for AI workloads.
      '';
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfg.ollama.enable) (mkMerge [
    {
      home.packages = [ ollama ];
    }

    (helpers.mkIfLinux {
      systemd.user.services.ollama = mkIf cfg.ollama.enableServer {
        Unit = {
          Description = "Ollama";
          Documentation = "https://github.com/jmorganca/ollama";
        };
        Install.WantedBy = [ "default.target" ];
        Service = {
          Environment = toEnvironmentCfg env;
          ExecStart = escapeShellArgs ollamaArgs;
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    })

    (helpers.mkIfDarwin {
      launchd.agents.ollama = mkIf cfg.ollama.enableServer{
        enable = true;
        config = {
          EnvironmentVariables = env;
          ProcessType = "Background";
          ProgramArguments = ollamaArgs;
          KeepAlive = {
            Crashed = true;
            SuccessfulExit = false;
          };
        };
      };
    })
  ]);
}
