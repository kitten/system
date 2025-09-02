{ lib, config, hostname, helpers, ... }:

with lib;
let
  address = config.modules.router.adress;
  cfg = config.modules.server;
in helpers.linuxAttrs {
  options.modules.server.tangled = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Tangled Knot.";
      type = types.bool;
    };

    owner = mkOption {
      default = "did:plc:726afsuwa5x6qaytybar3bfs";
      type = types.str;
    };

    hostname = mkOption {
      default = "knot.kitten.sh";
      type = types.str;
    };
  };

  config = mkIf (cfg.enable && cfg.tangled.enable) {
    services.tangled-knot = {
      enable = true;
      openFirewall = true;
      server = {
        hostname = cfg.tangled.hostname;
        listenAddr = "127.0.0.1:5555";
        owner = cfg.tangled.owner;
      };
    };
  };
}
