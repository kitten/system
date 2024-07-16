{ config, lib, pkgs, nixos-hardware, lanzaboote, modulesPath, ... }:

{
  imports = [
    nixos-hardware.nixosModules.framework-13-7040-amd
    lanzaboote.nixosModules.lanzaboote
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    bootspec.enable = true;

    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
      luks.devices."enc" = {
        device = "/dev/disk/by-label/NIXCRYPT";
        preLVM = true;
      };
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

    resumeDevice = "/dev/disk/by-label/NIXSWAP";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = [ "subvol=log" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-label/NIXSWAP"; }
  ];

  # prefer suspend-then-hibernate
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      LidSwitchIgnoreInhibited=no
      IdleAction=suspend-then-hibernate
      IdleActionSec=1m
    '';
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=2h
  '';

  # set host and allow unfree
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  # enable AMD microcode update and firmware
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;

  # enable bluetooth support
  hardware.bluetooth.enable = true;

  # enable media acceleration
  hardware.graphics.enable = true;

  # set regulatory domain for wireless chip
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="US"
  '';
}
