{ lib, pkgs, helpers, ... } @ inputs:

with lib;
let
  inherit (import ../../lib/colors.nix inputs) hex;
in helpers.linuxAttrs {
  environment.systemPackages = [ pkgs.sbctl ];

  console = {
    earlySetup = true;
    useXkbConfig = true;

    colors = [
      "000000"
      "${hex.red}"
      "${hex.green}"
      "${hex.yellow}"
      "${hex.blue}"
      "${hex.magenta}"
      "${hex.aqua}"
      "${hex.white}"
      "${hex.grey}"
      "${hex.brightRed}"
      "${hex.brightGreen}"
      "${hex.orange}"
      "${hex.brightBlue}"
      "${hex.pink}"
      "${hex.cyan}"
      "${hex.muted}"
    ];
  };

  boot = {
    bootspec.enable = mkDefault true;
    consoleLogLevel = mkDefault 2;

    loader = {
      timeout = mkDefault 2;
      systemd-boot.configurationLimit = mkDefault 3;
    };

    initrd = {
      verbose = false;
      systemd.enable = true;
    };

    kernelPackages = mkDefault pkgs.linuxPackages_latest;

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "nmi_watchdog=0"
      "mitigations=off"
    ];

    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 10;
      "vm.dirty_ratio" = 2;
      "vm.dirty_background_ratio" = 5;
      "net.ipv4.tcp_fin_timeout" = mkDefault 5;
      "net.ipv4.tcp_mtu_probing" = mkDefault true;
    };
  };

  time.timeZone = "Europe/London";

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_GB.UTF-8";
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
    };
    supportedLocales = [
      "en_GB.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  security = {
    sudo.enable = true;
    polkit.enable = true;
  };

  services.dbus.enable = true;

  virtualisation.oci-containers.backend = mkDefault "podman";
}
