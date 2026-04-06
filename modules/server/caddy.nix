{ lib, config, hostname, helpers, ... } @ inputs:

with lib;
let
  cfg = config.modules.server;
  cfgRouter = config.modules.router;

  domain = config.networking.domain;
  knotEnabled = cfg.tangled.enable;
  tailscaleEnabled = cfg.tailscale.enable;
  vaultwardenEnabled = cfg.vaultwarden.enable;
  jellyfinEnabled = cfg.jellyfin.enable;
  hassEnabled = cfg.home-assistant.enable;

  vaultwardenHandlerConfig = let
    port = toString cfg.vaultwarden.port;
    wsPort = toString cfg.vaultwarden.websocketPort;
  in if vaultwardenEnabled then ''
    handle_path /vault {
      redir * /vault/
    }

    handle_path /vault/* {
      reverse_proxy /notifications/hub/negotiate 127.0.0.1:${port}
      reverse_proxy /notifications/hub 127.0.0.1:${wsPort}
      reverse_proxy 127.0.0.1:${port} {
        header_up X-Real-IP {remote_host}
      }
    }
  '' else "";

  jellyfinHandlerConfig = if jellyfinEnabled then ''
    handle_path /media {
      redir * /media/
    }

    reverse_proxy /media/* 127.0.0.1:8096 {
      header_up X-Real-IP {remote_host}
    }
  '' else "";

  hassHandlerConfig = if hassEnabled && tailscaleEnabled then ''
    handle_path /home {
      redir * https://${hostname}.${domain}:8123
    }
  '' else "";

  tailscaleConfig = if tailscaleEnabled then ''
    ${hostname}.${domain} {
      bind tailscale0
      tls {
        protocols tls1.3
      }
      import network_paths
    }
  '' else "";

  knotConfig = let
    knotAddr = config.services.tangled.knot.server.listenAddr;
  in if knotEnabled then ''
    ${cfg.tangled.hostname} {
      log
      request_body {
        max_size 512MB
      }
      header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        Referrer-Policy strict-origin-when-cross-origin
        Strict-Transport-Security "max-age=31536000"
        -Server
      }
      handle /events {
        reverse_proxy ${knotAddr} {
          header_up X-Real-IP {remote_host}
          flush_interval -1
        }
      }
      reverse_proxy ${knotAddr} {
        header_up X-Real-IP {remote_host}
      }
    }
  '' else "";

  exposeConfig = let
    configs = attrsets.mapAttrsToList (name: root: ''
      handle_path /${name} {
        redir * /${name}/
      }

      handle_path /${name}/* {
        file_server {
          browse
          root ${root}
          hide .*
        }

        @file path *.*

        handle_path /* {
          header @file +Content-Disposition attachment
        }
      }
    '') cfg.caddy.exposeFolders;
  in strings.concatStringsSep "\n\n" configs;
in helpers.linuxAttrs {
  options.modules.server.caddy = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Caddy.";
      type = types.bool;
    };

    exposeFolders = mkOption {
      default = {};
      description = "Folders to expose via Caddy.";
      example = { files = "/share/files"; };
      type = types.attrsOf types.str;
    };
  };

  config = mkIf (cfg.enable && cfg.caddy.enable) {
    services.tailscale = mkIf tailscaleEnabled {
      permitCertUid = config.services.caddy.user;
    };

    services.caddy = {
      enable = true;
      email = "phil@kitten.sh";
      globalConfig = ''
        servers {
          timeouts {
            read_body   10s
            read_header 5s
            idle        60s
          }
          max_header_size 16384
          protocols h1 h2 h3
        }
      '';
      extraConfig = let
        addresses = filter (x: x != null) [ cfgRouter.address "127.0.0.1" "[::1]" ];
      in ''
        (network_paths) {
          request_body {
            max_size 10MB
          }
          header {
            X-Content-Type-Options nosniff
            X-Frame-Options SAMEORIGIN
            Referrer-Policy strict-origin-when-cross-origin
            Strict-Transport-Security "max-age=31536000"
            -Server
          }
          ${vaultwardenHandlerConfig}
          ${jellyfinHandlerConfig}
          ${hassHandlerConfig}
          ${exposeConfig}
        }

        ${tailscaleConfig}
        ${knotConfig}

        :80 {
          bind ${concatStringsSep " " addresses}
          redir https://${if cfgRouter.address != null then cfgRouter.address else "{host}"}{uri} permanent
        }

        :443 {
          bind ${concatStringsSep " " addresses}
          import network_paths
        }
      '';
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 443 ];
  };
}
