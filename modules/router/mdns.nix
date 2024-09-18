{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;
  intern = cfg.interfaces.internal;
  extern = cfg.interfaces.external;
in {
  options.modules.router = {
    mdns.enable = mkOption {
      default = cfg.enable;
      description = "Whether to enable mDNS Discovery Service";
      type = types.bool;
    };
  };

  config = mkIf cfg.mdns.enable && intern != null {
    services.avahi = {
      enable = true;
      allowInterfaces = if intern != null then [ intern.name ] else [];
      denyInterfaces = [ extern.name ];
    };
  };
}
