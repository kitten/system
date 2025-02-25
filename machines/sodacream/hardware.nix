{ lib, inputs, modulesPath, ... }:

with lib;
{
  imports = with inputs; [
    apple-silicon.nixosModules.apple-silicon-support
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostId = "1a99cdb0";

  boot = {
    supportedFilesystems = [ "btrfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };
    kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.zpool=zsmalloc"
      "zswap.max_pool_percent=20"
      "apple_dcp.show_notch=1"
      "nvme_apple.flush_interval=1000"
    ];
    initrd.luks.devices."cryptroot".device = "/dev/disk/by-label/NIXOS_LUKS";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=@root" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=@home" "noatime" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=@log" "noatime" ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=@swap" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9B6C-1522";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 16 * 1024;
    }
  ];

  nixpkgs.overlays = [ inputs.apple-silicon.overlays.apple-silicon-overlay ];

  hardware = {
    enableAllFirmware = true;
    graphics.enable = true;
    bluetooth.enable = true;
    wirelessRegulatoryDatabase = true;
    asahi.useExperimentalGPUDriver = true;
  };

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
  '';

  systemd.services = {
    mount-pstore.enable = mkDefault false;
    ModemManager.enable = mkDefault false;
  };
}
