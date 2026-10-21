{ pkgs, ... }:

{
  imports = [ ];

  modules = {
    agents.agent = {
      uid = 550;
      git.email = "phil+agent@kitten.sh";
      secrets.ssh = ../../modules/agent/encrypt/agent-ssh.age;
      home.modules.development = {
        enable = true;
        codex.enable = true;
        claude = {
          enable = true;
          environmentFile.enable = true;
        };
        cursor = {
          enable = true;
          environmentFile.enable = true;
        };
        grok = {
          enable = true;
          environmentFile.enable = true;
        };
        t3code.environmentFile.enable = true;
      };
    };
    vram = {
      wiredLimit = 8;
      wiredLowWatermark = 20;
    };
    server = {
      enable = true;
      sshd.enable = true;
      tailscale.enable = true;

      t3code = {
        enable = true;
        account = "agent";
      };
    };
  };
}
