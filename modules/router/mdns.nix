{ lib, config, ... }:

with lib;
let
  cfg = config.modules.router;
in {
  options.modules.router = {
    mdns.enable = mkOption {
      default = cfg.enable;
      description = "Whether to enable mDNS Discovery Service";
      type = types.bool;
    };
  };

  config = mkIf cfg.mdns.enable {
    services.avahi = {
      enable = true;
      allowInterfaces = [ cfg.interfaces.internal.name ];
      denyInterfaces = [ cfg.interfaces.external.name ];
    };
  };
}
