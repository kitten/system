{ config, ... }:

{
  services.tailscale.permitCertUid = config.services.caddy.user;

  services.caddy = {
    enable = config.services.tailscale.enable;
    email = "phil@kitten.sh";
    extraConfig = ''
      (network_paths) {
        handle_path /home {
          redir * https://cola.fable-pancake.ts.net:8123
        }

        handle_path /plex {
          redir * https://cola.fable-pancake.ts.net:32400
        }

        handle_path /vault {
          redir * /vault/
        }

        handle_path /vault/* {
          reverse_proxy /notifications/hub/negotiate 127.0.0.1:8000
          reverse_proxy /notifications/hub 127.0.0.1:8001
          reverse_proxy localhost:8000 {
            header_up X-Real-IP {remote_host}
          }
        }

        handle_path /files {
          redir * /files/
        }

        handle_path /files/* {
          file_server {
            browse
            root /share/files
            hide .*
          }

          @file path *.*

          handle_path /* {
            header @file +Content-Disposition attachment
          }
        }
      }

      cola.fable-pancake.ts.net {
        tls /var/lib/caddy/certificates/cola.fable-pancake.ts.net.crt /var/lib/caddy/certificates/cola.fable-pancake.ts.net.key
        import network_paths
      }

      :80 {
        import network_paths
      }
    '';
  };
}
