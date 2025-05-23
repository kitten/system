{ lib, ... }:

with lib;
{
  programs.ssh = {
    enable = true;
    compression = true;
    serverAliveCountMax = 5;
    serverAliveInterval = 60;
    matchBlocks."*" = {
      extraOptions.IPQoS = "none";
      setEnv.TERM = "xterm";
    };
  };
}
