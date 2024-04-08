{ ... }:

{
  networking = {
    useNetworkd = true;
    nameservers = [ "127.0.0.1" ];
    timeServers = [ "time.cloudflare.com" ];
    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "lo" "intern0" ];
    };
  };

  systemd.network = {
    enable = true;

    links."10-extern0" = {
      matchConfig.PermanentMACAddress = "1c:1b:0d:eb:ab:15";
      linkConfig = {
        Description = "External Network Interface";
        Name = "extern0";
        MACAddress = "64:20:9f:16:70:a6";
        MTUBytes = "1500";
      };
    };

    links."11-intern0" = {
      matchConfig.PermanentMACAddress = "1c:1b:0d:eb:ab:14";
      linkConfig = {
        Description = "Internal Network Interface";
        Name = "intern0";
        MTUBytes = "1500";
      };
    };

    networks."10-extern0" = {
      name = "extern0";
      networkConfig = {
        DHCP = "ipv4";
        DNS = "127.0.0.1";
        IPForward = true;
      };
      dhcpV4Config = {
        UseDNS = false;
        UseDomains = false;
        UseNTP = false;
      };
    };

    networks."11-intern0" = {
      name = "intern0";
      networkConfig = {
        Address = "10.0.0.1/24";
        DHCPServer = false;
        IPForward = true;
        ConfigureWithoutCarrier = true;
      };
    };
  };
}
