{ lib, config, pkgs, helpers, ... } @ inputs:

let
  inherit (import ../../lib/colors.nix inputs) hex;
  inherit (lib) mkDefault;
in helpers.linuxAttrs {
  environment.systemPackages = [ pkgs.sbctl ];

  console = {
    earlySetup = true;
    useXkbConfig = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

    colors = [
      "${hex.black}"
      "${hex.red}"
      "${hex.green}"
      "${hex.yellow}"
      "${hex.blue}"
      "${hex.pink}"
      "${hex.cyan}"
      "${hex.white}"
      "${hex.grey}"
      "${hex.brightRed}"
      "${hex.brightGreen}"
      "${hex.orange}"
      "${hex.brightBlue}"
      "${hex.purple}"
      "${hex.aqua}"
      "${hex.muted}"
    ];
  };

  boot = {
    bootspec.enable = lib.mkDefault true;
    consoleLogLevel = lib.mkDefault 2;

    loader = {
      timeout = mkDefault 2;
      systemd-boot.configurationLimit = mkDefault 3;
    };

    initrd = {
      verbose = false;
      systemd.enable = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "nmi_watchdog=0"
      "mitigations=off"
    ];

    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 10;
      "vm.dirty_ratio" = 2;
      "vm.dirty_background_ratio" = 5;
      "vm.max_map_count" = 262144;
    };
  };

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
}
