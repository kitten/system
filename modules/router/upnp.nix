{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;
in {
  options.modules.router = {
    upnp = {
      enable = mkOption {
        default = cfg.enable;
        description = "Whether to enable UPNP";
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.upnp.enable {
    services.miniupnpd = {
      enable = true;
      upnp = true;
      natpmp = true;
      internalIPs = [ cfg.interfaces.internal ];
      externalInterface = cfg.interfaces.external;
      appendConfig = ''
        secure_mode=yes
        notify_interval=60
        clean_ruleset_interval=600
        uuid=78b8b903-83c1-4036-8fcd-f64aee25baca
        allow 1024-65535 10.0.0.0/24 1024-65535
        deny 0-65535 0.0.0.0/0 0-65535
      '';
    };
  };
}
