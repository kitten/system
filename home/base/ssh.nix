{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "auto";
      ControlPath = "~/.ssh/master-%C";
      ControlPersist = "5m";

      Compression = true;
      ServerAliveInterval = 60;
      ServerAliveCountMax = 5;
      IPQoS = "none";
      SetEnv.TERM = "xterm";
    };
  };
}
