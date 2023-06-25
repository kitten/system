{ config, lib, pkgs, nixos-hardware, lanzaboote, modulesPath, ... }:

let
  luksUUID = "8f9546b5-56bb-42d3-a230-e81aef2faba5";
  rootUUID = "1e92c1b5-06de-4d3e-a381-782a9f34556d";
  swapUUID = "477573ca-2f72-402e-986e-1ac8de6082c7";
  bootUUID = "AD1D-0BB6";
in {
  imports = [
    nixos-hardware.nixosModules.framework-12th-gen-intel
    lanzaboote.nixosModules.lanzaboote
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    bootspec.enable = true;

    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
      luks.devices."enc" = {
        device = "/dev/disk/by-uuid/${luksUUID}";
        preLVM = true;
      };
    };
    kernelModules = [ "kvm-intel" ];
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

    resumeDevice = "/dev/disk/by-uuid/${swapUUID}";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${rootUUID}";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/${rootUUID}";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/${rootUUID}";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/${rootUUID}";
    fsType = "btrfs";
    options = [ "subvol=log" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/${bootUUID}";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/${swapUUID}"; }
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

  # set default power management
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # enable Intel microcode update and firmware
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;

  # enable media acceleration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };
}
