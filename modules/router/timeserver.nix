{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;

  bindDevices =
    strings.concatStringsSep "\n"
      (builtins.map (ifname: "binddevice ${ifname}")
        (lists.remove "lo" config.networking.firewall.trustedInterfaces));
in {
  options.modules.router = {
    timeserver.enable = mkOption {
      default = cfg.enable;
      description = "Whether to enable NTP Service";
      type = types.bool;
    };
  };

  config = mkIf cfg.timeserver.enable {
    networking.timeServers = [
      "time.cloudflare.com"
      "ntppool1.time.nl"
      "ptbtime1.ptb.de"
    ];

    services.chrony = {
      enable = true;
      extraFlags = mkDefault [
        "-F 1" # seccomp filter
        "-r" # reload history on restart
      ];
      initstepslew.enabled = mkDefault false;
      enableRTCTrimming = mkDefault false;
      enableNTS = mkDefault true;
      extraConfig = ''
        minsources 3
        authselectmode require
        dscp 46
        makestep 1.0 3
        cmdport 0
        noclientlog
        ${strings.optionalString (!config.services.chrony.enableRTCTrimming) "rtcsync"}
        allow all
        ${bindDevices}
      '';
    };

    services.timesyncd.enable = false;
    services.ntp.enable = false;
    services.openntpd.enable = false;
  };
}
