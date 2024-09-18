{ lib, config, helpers, ... }:

with lib;
let
  cfg = config.modules.router;
in {
  options.modules.router = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Router options.";
      type = types.bool;
    };

    interfaces = {
      external = mkOption {
        default = "extern0";
        type = types.str;
      };
      internal = mkOption {
        default = "intern0";
        type = types.str;
      };
    };
  };

  config.modules.router = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
  imports = [
    ./timeserver.nix
    ./dnsOverTLS.nix
    ./dnsmasq.nix
    ./nftables.nix
    ./upnp.nix
    ./mdns.nix
    ./kernel.nix
  ];

  config = mkIf cfg.enable {
    networking.firewall.trustedInterfaces = [
      cfg.interfaces.internal
    ];
  };
}
