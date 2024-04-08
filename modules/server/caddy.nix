{ ... }:

{
  services.caddy = {
    enable = true;
    email = "phil@kitten.sh";
    extraConfig = ''
      cola.fable-pancake.ts.net {
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
          reverse_proxy /notifications/hub/negotiate 0.0.0.0:8000
          reverse_proxy /notifications/hub 0.0.0.0:8001
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
    '';
  };
}
