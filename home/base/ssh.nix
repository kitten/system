{ lib, ... }:

with lib;
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";

      Compression = true;
      ServerAliveInterval = 60;
      ServerAliveCountMax = 5;
      IPQoS = "none";
      SetEnv.TERM = "xterm";
    };
  };
}
