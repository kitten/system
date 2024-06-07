{ ... }:

{
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
      listen_addresses = [ "127.0.0.1@53000" "0::1@53000" ];
      appdata_dir = "/var/cache/stubby";
      trust_anchors_backoff_time = 2500;
      upstream_recursive_servers = [
        { address_data = "1.1.1.1"; tls_auth_name = "cloudflare-dns.com"; }
        { address_data = "1.0.0.1"; tls_auth_name = "cloudflare-dns.com"; }
      ];
    };
  };
}
