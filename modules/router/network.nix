{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;

  interfaceType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        example = "eth0";
      };
      macAddress = mkOption {
        type = types.str;
        example = "00:00:00:00:00:00";
      };
    };
  };

  extern0 = cfg.interfaces.external.name;
  extern0MAC = cfg.interfaces.external.macAddress;
  intern0 = cfg.interfaces.internal.name;
  intern0MAC = cfg.interfaces.internal.macAddress;
in {
  options.modules.router = {
    interfaces = {
      external = interfaceType;
      internal = interfaceType;
    };
  };

  config = mkIf cfg.enable {
    services.irqbalance.enable = true;

    networking.firewall.trustedInterfaces = [ "lo" intern0 ];

    systemd.network = {
      enable = true;

      links."10-${extern0}" = {
        matchConfig.PermanentMACAddress = extern0MAC;
        linkConfig = {
          Description = "External Network Interface";
          Name = extern0;
          # MACAddress = "64:20:9f:16:70:a6";
          MTUBytes = "1500";
        };
      };

      links."11-${intern0}" = {
        matchConfig.PermanentMACAddress = intern0MAC;
        linkConfig = {
          Description = "Internal Network Interface";
          Name = intern0;
          MTUBytes = "1500";
        };
      };

      networks."10-${extern0}" = {
        name = extern0;
        networkConfig = {
          DHCP = "ipv4";
          DNS = if cfg.dnsmasq.enable then "127.0.0.1" else "1.1.1.1";
          IPForward = true;
        };
        dhcpV4Config = {
          UseDNS = false;
          UseDomains = false;
          UseNTP = !cfg.timeserver.enable;
        };
      };

      networks."11-${intern0}" = {
        name = intern0;
        networkConfig = {
          Address = "10.0.0.1/24";
          DHCPServer = false;
          IPForward = true;
          ConfigureWithoutCarrier = true;
        };
      };
    };
  };
}
