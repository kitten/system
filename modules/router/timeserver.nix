{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;

  intern = cfg.interfaces.internal;

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
    networking.timeServers = [ "time.cloudflare.com" ];

    services.chrony = {
      enable = true;
      enableNTS = true;
      extraConfig = ''
        allow ${intern.cidr}
        ${bindDevices}
      '';
    };

    services.ntp.enable = false;
    services.openntpd.enable = false;
  };
}
