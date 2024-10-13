{ lib, config, ... } @ inputs:

with lib;
let
  inherit (import ../../lib/ipv4.nix inputs) ipv4;

  cfg = config.modules.router;

  leaseType = types.submodule {
    options = {
      macAddress = mkOption {
        type = types.str;
        example = "00:00:00:00:00:00";
      };
      ipAddress = mkOption {
        type = types.str;
        example = "10.0.0.10";
      };
    };
  };

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
      adoptMacAddress = mkOption {
        type = types.nullOr types.str;
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
  options.modules.router = let
    defaultAddress = if intern != null
      then ipv4.prettyIp (ipv4.cidrToIpAddress intern.cidr)
      else "127.0.0.1";
  in {
    address = mkOption {
      type = types.str;
      default = defaultAddress;
      example = "127.0.0.1";
    };
    mdns = mkOption {
      type = types.bool;
      default = !config.services.avahi.enable;
    };
    ipv6 = mkOption {
      type = types.bool;
      default = false;
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
    leases = mkOption {
      default = [];
      type = types.listOf leaseType;
      description = "List of reserved IP address leases";
    };
  };

  config = let
    links = {
      "10-${extern.name}" = {
        matchConfig.PermanentMACAddress = extern.macAddress;
        linkConfig = {
          Description = "External Network Interface";
          Name = extern.name;
          MACAddress = extern.adoptMacAddress;
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
  in mkIf cfg.enable {
    networking = {
      useNetworkd = true;
      hosts."127.0.0.2" = mkForce [];
      networkmanager.enable = mkForce false;
      firewall = mkIf (intern != null) {
        trustedInterfaces = [ "lo" intern.name ];
      };
      nameservers = [
        "1.1.1.1#cloudflare-dns.com"
      ] ++ (if cfg.ipv6 then [ "2606:4700:4700::1111#cloudflare-dns.com" ] else []);
    };

    boot.initrd.systemd.network = {
      enable = true;
      inherit links;
    };

    systemd.network = {
      enable = true;
      inherit links;
      networks = let
        gatewayAddress = ipv4.prettyIp (ipv4.cidrToIpAddress intern.cidr);
      in {
        "10-${extern.name}" = {
          name = extern.name;
          networkConfig = {
            DHCP = if cfg.ipv6 then "yes" else "ipv4";
            IPv4Forwarding = true;
            IPv6Forwarding = true;
            IPv6AcceptRA = mkIf cfg.ipv6 true;
          };
          cakeConfig = {
            Parent = "root";
          };
          dhcpV4Config = {
            UseDNS = false;
            UseDomains = false;
            UseNTP = !cfg.timeserver.enable;
          };
          dhcpV6Config = mkIf cfg.ipv6 {
            WithoutRA = "solicit";
            UseDNS = false;
            UseDomains = false;
            UseAddress = false;
            DUIDType = "link-layer";
            DUIDRawData = mkIf (extern.adoptMacAddress != null) "00:01:${extern.adoptMacAddress}";
          };
          dhcpPrefixDelegationConfig = mkIf cfg.ipv6 {
            UplinkInterface = ":self";
            Announce = false;
          };
          ipv6AcceptRAConfig = mkIf cfg.ipv6 {
            UseDNS = false;
            UseDomains = false;
            DHCPv6Client = "always";
            Token = mkIf (extern.adoptMacAddress != null) "static:::${extern.adoptMacAddress}";
          };
        };
      } // (optionalAttrs (intern != null) {
        "11-${intern.name}" = {
          name = intern.name;
          networkConfig = {
            Address = intern.cidr;
            DHCPServer = true;
            IPv4Forwarding = true;
            IPv6Forwarding = cfg.ipv6;
            IPMasquerade = "ipv4";
            ConfigureWithoutCarrier = true;
            MulticastDNS = cfg.mdns;
            DHCPPrefixDelegation = cfg.ipv6;
            IPv6SendRA = cfg.ipv6;
            IPv6AcceptRA = mkIf cfg.ipv6 false;
          };
          fairQueueingControlledDelayConfig = {
            Parent = "root";
          };
          dhcpServerStaticLeases = builtins.map (lease: {
            Address = lease.ipAddress;
            MACAddress = lease.macAddress;
          }) cfg.leases;
          dhcpServerConfig = {
            EmitDNS = true;
            EmitNTP = true;
            DNS = gatewayAddress;
            NTP = gatewayAddress;
            DefaultLeaseTimeSec = 43200;
            MaxLeaseTimeSec = 86400;
          };
          dhcpPrefixDelegationConfig = mkIf cfg.ipv6 {
            UplinkInterface = extern.name;
            Token = "static:::1";
            Announce = true;
          };
        };
      });
    };

    services.irqbalance.enable = true;

    services.resolved = {
      enable = true;
      llmnr = "false";
      domains = [ "~." ];
      fallbackDns = [
        "1.0.0.1"
      ] ++ (if cfg.ipv6 then [ "2606:4700:4700::1001" ] else []);
      dnsovertls = "opportunistic";
      extraConfig = strings.concatStringsSep "\n" [
        "[Resolve]"
        (optionalString cfg.mdns ''
          MulticastDNS=yes
        '')
        (optionalString (intern != null) ''
          DNSStubListener=yes
          DNSStubListenerExtra=${ipv4.prettyIp (ipv4.cidrToIpAddress intern.cidr)}
        '')
      ];
    };
  };
}
