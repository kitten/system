{ lib, config, ... } @ inputs:

with lib;
let
  inherit (import ../../lib/ipv4.nix inputs) ipv4;

  cfg = config.modules.router;
  intern = cfg.interfaces.internal;
  extern = cfg.interfaces.external;

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

  dnsServer = if cfg.dnsOverTLS.enable
    then [ "127.0.0.1#${cfg.dnsOverTLS.port}" ]
    else [ "1.1.1.1" "1.0.0.1" ];

  dhcpHost = builtins.map (lease: "${lease.macAddress},${lease.ipAddress}") cfg.dnsmasq.leases;

  dhcpIPv4Range = let
    subnetMask = ipv4.prettyIp (ipv4.cidrToSubnetMask intern.cidr);
    firstIP = ipv4.prettyIp (ipv4.incrementIp (ipv4.cidrToFirstUsableIp intern.cidr) 1);
    lastIP = ipv4.prettyIp (ipv4.cidrToLastUsableIp intern.cidr);
  in "${firstIP}, ${lastIP}, ${subnetMask}, 12h";

  localDomains = builtins.map (host: "/${host}/${cfg.address}") cfg.dnsmasq.localDomains;
in {
  options.modules.router = {
    dnsmasq = {
      enable = mkOption {
        default = cfg.enable;
        description = "Whether to enable DNSMasq";
        type = types.bool;
      };

      leases = mkOption {
        default = [];
        type = types.listOf leaseType;
        description = "List of reserved IP address leases";
      };

      localDomains = mkOption {
        default = [];
        type = types.listOf types.str;
      };
    };
  };

  config = mkIf cfg.dnsmasq.enable {
    modules.router.dnsmasq.localDomains = [
      "time.apple.com"
      "time1.apple.com"
      "time2.apple.com"
      "time3.apple.com"
      "time4.apple.com"
      "time5.apple.com"
      "time6.apple.com"
      "time7.apple.com"
      "time.euro.apple.com"
      "time.windows.com"
      "0.android.pool.ntp.org"
      "1.android.pool.ntp.org"
      "2.android.pool.ntp.org"
      "3.android.pool.ntp.org"
    ];

    networking.nameservers = [ "127.0.0.1" ];

    services.resolved.extraConfig = mkDefault ''
      [Resolve]
      DNSStubListener=no
    '';

    services.dnsmasq = {
      enable = true;
      alwaysKeepRunning = true;
      settings = {
        server = dnsServer;

        # never forward plain names (without a dot or domain part)
        domain-needed = true;
        # never forward addresses in the non-routed address spaces.
        bogus-priv = true;
        # filter useless windows-originated DNS requests
        filterwin2k = true;
        # never read nameservers from /etc/resolv.conf
        no-resolv = true;

        cache-size = 5000;
        no-negcache = true;

        expand-hosts = true;
        addn-hosts = "/etc/hosts";

        dhcp-range = mkIf intern != null [
          dhcpIPv4Range
          "tag:${intern.name}, ::1, constructor:${intern.name}, ra-names, slaac, 12h"
        ];

        dhcp-option = if intern != null then
          [
            "option6:information-refresh-time, 6h"
            "option:router,${cfg.address}"
            "ra-param=${intern.name},high,0,0"
          ] ++ (
            if cfg.timeserver.enable then [ "option:ntp-server,${cfg.address}" ] else []
          )
        else [];

        dhcp-host = dhcpHost;

        # listen only on intern0 by excluding extern0
        except-interface = extern.name;

        # set the DHCP server to authoritative and rapic commit mode
        dhcp-authoritative = true;
        dhcp-rapid-commit = true;

        # Detect attempts by Verisign to send queries to unregistered hosts
        bogus-nxdomain = "64.94.110.11";

        address = localDomains;
      };
    };
  };
}
