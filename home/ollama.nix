{ helpers, lib, pkgs, ... }:

let
  ollamaArgs = [
    "${pkgs.ollama}/bin/ollama"
    "serve"
  ];
in {
  config = lib.mkMerge [
    { home.packages = [ pkgs.ollama ]; }

    (helpers.mkIfLinux {
      systemd.user.services.ollama = {
        Unit = {
          Description = "Ollama";
          Documentation = "https://github.com/jmorganca/ollama";
        };
        Install.WantedBy = [ "default.target" ];
        Service = {
          ExecStart = lib.escapeShellArgs ollamaArgs;
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
  ];
}
