{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;
  extern = cfg.interfaces.external;
  intern = cfg.interfaces.internal;
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

  config = mkIf (cfg.upnp.enable && intern != null) {
    services.miniupnpd = {
      enable = true;
      upnp = true;
      natpmp = true;
      internalIPs = if intern != null then [ intern.name ] else [];
      externalInterface = extern.name;
      appendConfig = ''
        secure_mode=yes
        notify_interval=60
        clean_ruleset_interval=600
        uuid=78b8b903-83c1-4036-8fcd-f64aee25baca
        allow 1024-65535 ${intern.cidr} 1024-65535
        deny 0-65535 ${extern.cidr} 0-65535
      '';
    };
  };
}
