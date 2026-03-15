{ lib, pkgs, config, ... } @ inputs:

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

  pppType = types.submodule {
    options = {
      enable = mkOption {
        default = false;
        example = true;
        description = "Whether to enable PPPoE";
        type = types.bool;
      };
      mtu = mkOption {
        default = null;
        type = types.nullOr types.int;
      };
    };
  };

  ppp = cfg.ppp;
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
    ppp = mkOption {
      default = { };
      type = pppType;
    };
  };

  config = let
    links = {
      "10-${extern.name}" = {
        matchConfig.PermanentMACAddress = extern.macAddress;
        linkConfig = if ppp.enable then {
          Description = "PPPoE Network Interface";
          Name = "wan";
          MACAddress = extern.adoptMacAddress;
          MTUBytes = mkIf (ppp.mtu != null) (toString (ppp.mtu + 8));
        } else {
          Description = "External Network Interface";
          Name = extern.name;
          MACAddress = extern.adoptMacAddress;
          MTUBytes = "1500";
        };
      };
    } // (optionalAttrs ppp.enable {
      "10-ppp" = {
        matchConfig.Type = "ppp";
        linkConfig = {
          Description = "External Network Interface";
          Name = extern.name;
        };
      };
    }) // (optionalAttrs (intern != null) {
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
        "9.9.9.9#dns.quad9.net"
        "8.8.8.8#dns.google"
      ] ++ (optionals cfg.ipv6 [
        "2606:4700:4700::1111#cloudflare-dns.com"
        "2620:fe::9#dns.quad9.net"
        "2001:4860:4860::8888#dns.google"
      ]);
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
            DHCP = if ppp.enable
              then if cfg.ipv6 then "ipv6" else "no"
              else if cfg.ipv6 then "yes" else "ipv4";
            IPv4Forwarding = true;
            IPv6Forwarding = true;
            IPv6AcceptRA = mkIf cfg.ipv6 true;
            LinkLocalAddressing = mkIf cfg.ipv6 "ipv6";
            KeepConfiguration = mkIf ppp.enable "static";
            DefaultRouteOnDevice = mkIf ppp.enable true;
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
            UseNTP = true;
            UseDNS = false;
            UseDomains = false;
            UseAddress = false;
            DUIDType = "link-layer";
            DUIDRawData = mkIf (extern.adoptMacAddress != null) "00:01:${extern.adoptMacAddress}";
          };
          dhcpPrefixDelegationConfig = mkIf cfg.ipv6 {
            UplinkInterface = ":self";
            SubnetId = 0;
            Announce = false;
          };
          ipv6AcceptRAConfig = mkIf cfg.ipv6 {
            UseDNS = false;
            UseDomains = false;
            UseMTU = false;
            UseOnLinkPrefix = false;
            DHCPv6Client = "always";
            Token = mkIf (extern.adoptMacAddress != null) "static:::${extern.adoptMacAddress}";
          };
          routes = optionals ppp.enable [
            { Gateway = "::"; }
          ];
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
      }) // (optionalAttrs ppp.enable {
        "10-ppp" = {
          name = "wan";
          networkConfig.ConfigureWithoutCarrier = true;
        };
      });
    };

    services.pppd = mkIf ppp.enable {
      enable = true;
      peers.extern.config = ''
        plugin pppoe.so wan
        ifname ${extern.name}
        noipdefault
        defaultroute
        replacedefaultroute
        persist
        maxfail 0
        holdoff 5
        lcp-echo-adaptive
        default-asyncmap
        noaccomp
        file ${config.age.secrets.pppoe-options.path}
        ${optionalString cfg.ipv6 "+ipv6"}
        ${optionalString (ppp.mtu != null) "mtu ${toString ppp.mtu}"}
        ${optionalString (ppp.mtu != null) "mru ${toString ppp.mtu}"}
      '';
    };

    age.secrets.pppoe-options = mkIf ppp.enable {
      file = ./encrypt/pppoe-options.age;
    };

    services.resolved = {
      enable = true;
      settings.Resolve = mkMerge [
        {
          LLMNR = false;
          Domains = [ "~." ];
          FallbackDNS = [
            "1.0.0.1"
            "8.8.4.4"
          ] ++ (optionals cfg.ipv6 [
            "2606:4700:4700::1001"
            "2001:4860:4860::8844"
          ]);
          DNSOverTLS = "opportunistic";
          MulticastDNS = mkIf cfg.mdns true;
        }
        (mkIf cfg.mdns {
          MulticastDNS = true;
        })
        (mkIf (intern != null) {
          DNSStubListener = true;
          DNSStubListenerExtra = ipv4.prettyIp (ipv4.cidrToIpAddress intern.cidr);
        })
      ];
    };
  };
}
