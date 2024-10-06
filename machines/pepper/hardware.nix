{ lib, inputs, modulesPath, ... }:

{
  imports = with inputs; [
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-cpu-amd-pstate
    nixos-hardware.nixosModules.common-gpu-amd
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-pc
    lanzaboote.nixosModules.lanzaboote
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    bootspec.enable = true;

    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "btrfs" ];

    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      configurationLimit = 3;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=@root" "noatime" ];
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

  fileSystems."/swap" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=@swap" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [
    { device = "/swap/swapfile"; }
  ];

  hardware = {
    enableAllFirmware = true;
    graphics.enable = true;
    wirelessRegulatoryDatabase = true;
  };
}
