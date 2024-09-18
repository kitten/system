{ lib, config, ... } @ inputs:

with lib;
let
  inherit (import ../../lib/ipv4.nix inputs) ipv4;

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
      cidr = mkOption {
        type = types.str;
        default = "0.0.0.0/0";
        example = "10.0.0.1/24";
      };
    };
  };

  extern = cfg.interfaces.external;
  intern = cfg.interfaces.internal;
in {
  options.modules.router = {
    address = mkOption {
      type = types.str;
      default = if intern != null
        then ipv4.prettyIp (ipv4.cidrToIpAddress intern.cidr)
        else "127.0.0.1";
      example = "127.0.0.1";
    };
    interfaces = {
      external = mkOption {
        type = interfaceType;
      };
      internal = mkOption {
        type = types.nullOr interfaceType;
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    services.irqbalance.enable = true;

    networking.useNetworkd = true;

    networking.firewall = mkIf (intern != null) {
      trustedInterfaces = [ "lo" intern.name ];
    };

    systemd.network = {
      enable = true;

      links = {
        "10-${extern.name}" = {
          matchConfig.PermanentMACAddress = extern.macAddress;
          linkConfig = {
            Description = "External Network Interface";
            Name = extern.name;
            # MACAddress = "64:20:9f:16:70:a6";
            MTUBytes = "1500";
          };
        };
      } // (optionalAttrs (intern != null) {
        "11-${intern.name}" = {
          matchConfig.PermanentMACAddress = intern.macAddress;
          linkConfig = {
            Description = "Internal Network Interface";
            Name = intern.name;
            MTUBytes = "1500";
          };
        };
      });

      networks = {
        "10-${extern.name}" = {
          name = extern.name;
          networkConfig = {
            DHCP = "ipv4";
            DNS = if cfg.dnsmasq.enable then "127.0.0.1" else "1.1.1.1";
            IPv4Forwarding = true;
            IPv6Forwarding = true;
          };
          dhcpV4Config = {
            UseDNS = false;
            UseDomains = false;
            UseNTP = !cfg.timeserver.enable;
          };
        };
      } // (optionalAttrs (intern != null) {
        "11-${intern.name}" = {
          name = intern.name;
          networkConfig = {
            Address = cfg.address;
            DHCPServer = false;
            IPv4Forwarding = true;
            IPv6Forwarding = true;
            ConfigureWithoutCarrier = true;
          };
        };
      });
    };
  };
}
