{ lib, config, pkgs, ... }:

with lib;
let
  cfgRoot = config.modules.server;
  cfg = config.modules.server.hd-idle;
in {
  options.modules.server.hd-idle = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable hard-drive idling.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfgRoot.enable) {
    systemd.services.hd-idle = {
      description = "External HD spin down daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 600";
      };
    };
  };
}
