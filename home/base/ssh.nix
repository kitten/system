{ lib, ... }:

with lib;
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";

      compression = true;
      serverAliveInterval = 60;
      serverAliveCountMax = 5;
      extraOptions.IPQoS = "none";
      setEnv.TERM = "xterm";
    };
  };
}
