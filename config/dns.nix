{
  imports = [
    ../modules/dnscrypt.nix
  ];

  services.dnscrypt2 = {
    enable = false;

    settings = {
      listen_addresses = [ "127.0.0.1:53" ];
      max_clients = 50;
      ipv4_servers = true;
      ipv6_servers = false;
      doh_servers = true;
      force_tcp = false;

      timeout = 1000;
      keepalive = 30;
      cert_refresh_delay = 240;
      netprobe_timeout = 60;
      netprobe_address = "1.1.1.1:53";

      fallback_resolvers = [ "1.1.1.1:53" "1.0.0.1:53" ];
      ignore_system_dns = true;

      block_unqualified = true;
      block_undelegated = true;
      block_ipv6 = false;
      reject_ttl = 600;

      cache = true;
      cache_size = 4096;
      cache_min_ttl = 2400;
      cache_max_ttl = 86400;
      cache_neg_min_ttl = 60;
      cache_neg_max_ttl = 600;

      require_dnssec = true;
      require_nolog = true;
      require_nofilter = false;

      sources.public_resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        prefix = "";
      };

      server_names = [ "cloudflare" "cloudflare-ipv6" ];
    };
  };
}
