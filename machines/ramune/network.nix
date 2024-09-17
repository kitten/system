{ ... }:

{
  services.irqbalance.enable = true;

  networking = {
    useNetworkd = true;
    nameservers = [ "127.0.0.1" ];
    timeServers = [ "time.cloudflare.com" ];
    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "lo" ];
    };
  };

  systemd.network = {
    enable = true;

    links."10-extern0" = {
      matchConfig.PermanentMACAddress = "5c:1b:f4:7f:dc:cd";
      linkConfig = {
        Description = "External Network Interface";
        Name = "extern0";
        # MACAddress = "64:20:9f:16:70:a6";
        MTUBytes = "1500";
      };
    };

    links."11-intern0" = {
      matchConfig.PermanentMACAddress = "9c:bf:0d:00:23:5d";
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
        IPv4Forwarding = true;
        IPv6Forwarding = true;
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
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        ConfigureWithoutCarrier = true;
      };
    };
  };
}
