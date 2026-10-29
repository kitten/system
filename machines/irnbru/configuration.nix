{ pkgs, ... }:

{
  imports = [ ];

  modules = {
    agents.agent = {
      uid = 550;
      git.email = "phil+agent@kitten.sh";
      secrets = {
        ssh = ../../modules/agent/encrypt/agent-ssh.age;
        env = ../../modules/agent/encrypt/agent.env.age;
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
