{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;
in {
  options.modules.router = {
    dnsOverTLS = {
      enable = mkOption {
        default = cfg.enable;
        description = "Whether to enable Stubby DNS proxy";
        type = types.bool;
      };

      port = mkOption {
        default = 53000;
        description = "Port for Stubby";
        type = types.int;
      };
    };
  };

  config = mkIf cfg.dnsOverTLS.enable {
    services.stubby = {
      enable = true;
      settings = {
        resolution_type = "GETDNS_RESOLUTION_STUB";
        dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
        tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
        tls_query_padding_blocksize = 128;
        edns_client_subnet_private = 1;
        round_robin_upstreams = 1;
        tls_connection_retries = 5;
        listen_addresses = [
          "127.0.0.1@${toString cfg.dnsOverTLS.port}"
          "0::1@${toString cfg.dnsOverTLS.port}"
        ];
        appdata_dir = "/var/cache/stubby";
        trust_anchors_backoff_time = 2500;
        upstream_recursive_servers = [
          { address_data = "1.1.1.1"; tls_auth_name = "cloudflare-dns.com"; }
          { address_data = "1.0.0.1"; tls_auth_name = "cloudflare-dns.com"; }
        ];
      };
    };
  };
}
