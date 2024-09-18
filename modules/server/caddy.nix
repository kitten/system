{ lib, config, hostname, ... }:

with lib;
let
  cfgRoot = config.modules.server;
  cfg = config.modules.server.caddy;

  exposeType = types.submodule {
    options = {
      path = mkOption {
        type = types.str;
        example = "/share/files";
      };
    };
  };

  domain = config.networking.domain;
  tailscaleEnabled = cfgRoot.tailscale.enable;
  vaultwardenEnabled = cfgRoot.vaultwarden.enable;
  jellyfinEnabled = cfgRoot.jellyfin.enable;
  hassEnabled = cfgRoot.home-assistant.enable;

  vaultwardenHandlerConfig = if vaultwardenEnabled then ''
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
  '' else "";

  jellyfinHandlerConfig = if jellyfinEnabled then ''
    handle_path /media {
      redir * /media/
    }

    reverse_proxy /media/* localhost:8096 {
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
      import network_paths
    }
  '' else "";

  exposeConfig = let
    configs = attrsets.mapAttrs (name: expose: ''
      handle_path /${name} {
        redir * /${name}/
      }

      handle_path /${name}/* {
        file_server {
          browse
          root ${expose.path}
          hide .*
        }

        @file path *.*

        handle_path /* {
          header @file +Content-Disposition attachment
        }
      }
    '') cfg.exposeFolders;
  in string.concatMapStringsSep "\n\n" configs;
in {
  options.modules.server.caddy = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Caddy.";
      type = types.bool;
    };

    exposeFolders = mkOption {
      default = {};
      description = "Folders to expose via Cadddy.";
      type = types.nullOr types.attrsOf exposeType;
    };
  };

  config = mkIf cfg.enable && cfgRoot.enable {
    services.tailscale = mkIf tailscaleEnabled {
      permitCertUid = config.services.caddy.user;
    };

    services.caddy = {
      enable = true;
      email = "phil@kitten.sh";
      extraConfig = ''
        (network_paths) {
          ${vaultwardenHandlerConfig}
          ${jellyfinHandlerConfig}
          ${hassHandlerConfig}
          ${exposeConfig}
        }

        ${tailscaleConfig}

        :80 {
          import network_paths
        }
      '';
    };
  };
}
