{ config, lib, pkgs, nixos-hardware, modulesPath, ... }:

{
  imports = [
    nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-pc
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "uas" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelParams = [ "mitigations=off" "systemd.unified_cgroup_hierarchy=false" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "btrfs" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    resumeDevice = "/dev/disk/by-label/NIXSWAP";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=@root" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [ "defaults" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=@nix" "noatime" "compress=zstd" ];
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

  swapDevices = [
    { device = "/dev/disk/by-label/NIXSWAP"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  # set host and allow unfree
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  # enable Intel microcode update and firmware
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;

  # enable media acceleration
  hardware.opengl.enable = true;
}
