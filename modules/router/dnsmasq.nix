{ config, lib, ... }:

{
  services.resolved.extraConfig = lib.mkDefault ''
    [Resolve]
    DNSStubListener=no
  '';

  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      server = if config.services.stubby.enable then [ "127.0.0.1#53000" ] else [ "1.1.1.1" "1.0.0.1" ];

      # never forward plain names (without a dot or domain part)
      domain-needed = true;
      # never forward addresses in the non-routed address spaces.
      bogus-priv = true;
      # filter useless windows-originated DNS requests
      filterwin2k = true;
      # never read nameservers from /etc/resolv.conf
      no-resolv = true;

      cache-size = 1500;
      no-negcache = true;

      expand-hosts = true;
      addn-hosts = "/etc/hosts";

      dhcp-range = [
        "10.0.0.2, 10.0.0.255, 255.255.255.0, 12h"
        "tag:intern0, ::1, constructor:intern0, ra-names, slaac, 12h"
      ];
      dhcp-option = [
        "option6:information-refresh-time, 6h"
        "option:router,10.0.0.1"
        "option:ntp-server,10.0.0.1"
        "ra-param=intern0,high,0,0"
      ];

      dhcp-host = [
        "98:ed:7e:c6:57:b2,10.0.0.102" # eero router
        "c4:f1:74:51:4c:f2,10.0.0.124" # eero router
        "5c:61:99:7a:16:40,10.0.0.103" # brother printer
        "24:e8:53:95:e4:02,10.0.0.96" # tv
        "34:7e:5c:31:4f:fa,10.0.0.56" # sonos
      ];

      # listen only on intern0 by excluding extern0
      except-interface = "extern0";

      # set the DHCP server to authoritative and rapic commit mode
      dhcp-authoritative = true;
      dhcp-rapid-commit = true;

      # Detect attempts by Verisign to send queries to unregistered hosts
      bogus-nxdomain = "64.94.110.11";

      address = [
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
        "/time.google.com/10.0.0.1"
        "/time1.google.com/10.0.0.1"
        "/time2.google.com/10.0.0.1"
        "/time3.google.com/10.0.0.1"
        "/time4.google.com/10.0.0.1"
        "/0.android.pool.ntp.org/10.0.0.1"
        "/1.android.pool.ntp.org/10.0.0.1"
        "/2.android.pool.ntp.org/10.0.0.1"
        "/3.android.pool.ntp.org/10.0.0.1"
      ];
    };
  };
}
