{ lib, config, hostname, helpers, ... }:

with lib;
let
  address = config.modules.router.address;
  cfg = config.modules.server;
in helpers.linuxAttrs {
  options.modules.server.vaultwarden = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Vaultwarden.";
      type = types.bool;
    };

    port = mkOption {
      default = 8000;
      description = "Vaultwarden HTTP port.";
      type = types.port;
    };

    websocketPort = mkOption {
      default = 8001;
      description = "Vaultwarden WebSocket port.";
      type = types.port;
    };
  };

  config = mkIf (cfg.enable && cfg.vaultwarden.enable) {
    modules.server.backup.paths.vaultwarden = {
      path = "/var/lib/vaultwarden";
      sqlite = "db.sqlite3";
      extras = [ "attachments" "rsa_key.pem" "rsa_key.pub.pem" ];
    };

    age.secrets."vaultwarden" = {
      symlink = true;
      path = "/run/secrets/vaultwarden.env";
      file = ./encrypt/vaultwarden.age;
    };

    services.vaultwarden = let
      baseURL = if (cfg.caddy.enable && cfg.tailscale.enable)
        then "https://${hostname}.${cfg.tailscale.domain}/vault/"
        else if cfg.caddy.enable then "http://${address}/vault/"
        else "http://${address}:${toString cfg.vaultwarden.port}/vault/";
    in {
      enable = true;
      dbBackend = "sqlite";
      environmentFile = "/run/secrets/vaultwarden.env";
      config = {
        IP_HEADER = "X-Real-IP";
        DOMAIN = baseURL;
        WEBSOCKET_ADDRESS = "127.0.0.1";
        ROCKET_ADDRESS = "127.0.0.1";
        WEBSOCKET_PORT = toString cfg.vaultwarden.websocketPort;
        ROCKET_PORT = toString cfg.vaultwarden.port;
        ROCKET_LIMITS = "{json=10485760}";

        LOGIN_RATELIMIT_SECONDS = "60";
        LOGIN_RATELIMIT_MAX_BURST = "10";
        ADMIN_RATELIMIT_SECONDS = "300";
        ADMIN_RATELIMIT_MAX_BURST = "3";

        PASSWORD_HINTS_ALLOWED = "false";
        SHOW_PASSWORD_HINT = "false";
        SIGNUPS_ALLOWED = "false";
        INVITATIONS_ALLOWED = "false";
        EMERGENCY_ACCESS_ALLOWED = "false";
        SENDS_ALLOWED = "false";
        ORG_CREATION_USERS = "none";
      };
    };
  };
}
