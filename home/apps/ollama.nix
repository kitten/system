{ lib, config, helpers, pkgs, ... }:

with lib;
let
  cfg = config.modules.apps;
  ollamaArgs = [
    "${pkgs.ollama}/bin/ollama"
    "serve"
  ];

  toEnvironmentCfg = vars: mapAttrsToList (k: v: "${k}=${escapeShellArg v}") vars;

  env = {
    OLLAMA_HOST = cfg.ollama.host;
    OLLAMA_FLASH_ATTENTION = if cfg.ollama.flashAttention then "1" else "0";
    OLLAMA_SCHED_SPREAD = if cfg.ollama.schedSpread then "1" else "0";
    OLLAMA_INTEL_GPU = if cfg.ollama.intelGpu then "1" else "0";
  };
in {
  options.modules.apps.ollama = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Ollama.";
      type = types.bool;
    };

    host = mkOption {
      default = "http://0.0.0.0:11434";
      description = "Determines the host and port to listen on";
      type = types.str;
    };

    flashAttention = mkOption {
      default = false;
      description = ''
        Enables experimental flash att  ention feature.
        Effect: Activates an experimental optimization for attention mechanisms.
        Scenario: Can potentially improve performance on compatible hardware but may introduce instability.
      '';
      type = types.bool;
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
      home.packages = [ pkgs.ollama ];
    }

    (helpers.mkIfLinux {
      systemd.user.services.ollama = {
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
      launchd.agents.ollama = {
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
