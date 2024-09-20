{ lib, config, helpers, pkgs, ... }:

with lib;
let
  cfg = config.modules.apps;
  ollamaArgs = [
    "${pkgs.ollama}/bin/ollama"
    "serve"
  ];
in {
  options.modules.apps.ollama = {
    enable = mkOption {
      default = false;
      description = "Whether to enable Ollama.";
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
