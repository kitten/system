{ config, ... }:

{
  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    zfs.extraPools = [ "colapool" ];
  };

  services.zfs = {
    expandOnBoot = [ "colapool" ];
    autoScrub = {
      pools = [ "colapool" ];
      interval = "Sun, 05:00";
      enable = true;
    };
  };
}
