{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;

  listenInterfaces =
    strings.concatStringsSep "\n"
      (builtins.map (ifname: "interface listen ${ifname}") config.networking.firewall.trustedInterfaces);

  ntpExtraConfig = ''
    ${listenInterfaces}
    interface ignore ${cfg.interfaces.external.name}
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
