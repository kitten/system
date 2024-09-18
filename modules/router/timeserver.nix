{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;

  ntpExtraConfig = ''
    interface listen lo
    interface listen ${cfg.interfaces.internal}
    interface ignore ${cfg.interfaces.external}
  '';
in {
  options.modules.router = {
    timeserver.enable = mkOption {
      default = cfg.enable;
      description = "Whether to enable NTP Service";
      type = types.bool;
    };
  };

  config = mkIf cfg.timeserver.enable {
    networking.timeServers = [ "time.cloudflare.com" ];

    services.ntp = {
      enable = true;
      extraConfig = ntpExtraConfig;
    };
  };
}
