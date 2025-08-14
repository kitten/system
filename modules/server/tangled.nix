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

    hostname = mkOption {
      default = "knot.kitten.sh";
      type = types.str;
    };
  };

  config = mkIf (cfg.enable && cfg.tangled.enable) {
    age.secrets."tangled-knot" = let
      inherit (config.services.tangled-knot) gitUser;
    in {
      file = ./encrypt/tangled-knot-secret.age;
      owner = gitUser;
      group = gitUser;
      mode = "0440";
    };

    services.tangled-knot = {
      enable = true;
      openFirewall = true;
      server = {
        hostname = cfg.tangled.hostname;
        listenAddr = "127.0.0.1:5555";
        secretFile = config.age.secrets."tangled-knot".path;
      };
    };
  };
}
