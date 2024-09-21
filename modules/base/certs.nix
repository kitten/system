{ lib, config, ... }:

with lib;
let
  cfg = config.modules.gpg;
in {
  options.modules.certs = {
    enable = mkOption {
      default = true;
      description = "CA Certificates";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    security.pki.certificateFiles = [ ./certs/ca.crt ];
  };
}

