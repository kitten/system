{ lib, config, ... }:

with lib;
let
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

  dnsServer = if cfg.dnsOverTLS.enable
    then [ "127.0.0.1#${cfg.dnsOverTLS.port}" ]
    else [ "1.1.1.1" "1.0.0.1" ];

  dhcpHost = builtins.map (lease: "${lease.macAddress},${lease.ipAddress}") cfg.dnsmasq.leases;
in {
  options.modules.router = {
    dnsmasq = {
      enable = mkOption {
        default = cfg.enable;
        description = "Whether to enable DNSMasq";
        type = types.bool;
      };

      leases = lib.mkOption {
        default = [];
        type = lib.types.listOf leaseType;
        description = "List of reserved IP address leases";
      };
    };
  };

  config = mkIf cfg.dnsmasq.enable {
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

        dhcp-range = [
          "10.0.0.2, 10.0.0.255, 255.255.255.0, 12h"
          "tag:${cfg.interfaces.internal}, ::1, constructor:${cfg.interfaces.internal}, ra-names, slaac, 12h"
        ];

        dhcp-option = [
          "option6:information-refresh-time, 6h"
          "option:router,10.0.0.1"
          "ra-param=${cfg.interfaces.internal},high,0,0"
        ];

        dhcp-option = mkIf cfg.timeserver.enable [
          "option:ntp-server,10.0.0.1"
        ];

        dhcp-host = dhcpHost;

        # listen only on intern0 by excluding extern0
        except-interface = cfg.interfaces.external;

        # set the DHCP server to authoritative and rapic commit mode
        dhcp-authoritative = true;
        dhcp-rapid-commit = true;

        # Detect attempts by Verisign to send queries to unregistered hosts
        bogus-nxdomain = "64.94.110.11";

        address = [
          "/cola.fable-pancake.ts.net/10.0.0.1"
          "/time.apple.com/10.0.0.1"
          "/time1.apple.com/10.0.0.1"
          "/time2.apple.com/10.0.0.1"
          "/time3.apple.com/10.0.0.1"
          "/time4.apple.com/10.0.0.1"
          "/time5.apple.com/10.0.0.1"
          "/time6.apple.com/10.0.0.1"
          "/time7.apple.com/10.0.0.1"
          "/time.euro.apple.com/10.0.0.1"
          "/time.windows.com/10.0.0.1"
          "/0.android.pool.ntp.org/10.0.0.1"
          "/1.android.pool.ntp.org/10.0.0.1"
          "/2.android.pool.ntp.org/10.0.0.1"
          "/3.android.pool.ntp.org/10.0.0.1"
        ];
      };
    };
  };
}
