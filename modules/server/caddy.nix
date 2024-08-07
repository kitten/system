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

        handle_path /media {
          redir * /media/
        }

        reverse_proxy /media/* localhost:8096 {
          header_up X-Real-IP {remote_host}
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
        import network_paths
      }

      :80 {
        import network_paths
      }
    '';
  };
}
