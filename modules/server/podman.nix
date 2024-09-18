{ lib, config, ... }:

with lib;
let
  cfgRoot = config.modules.server;
  cfg = config.modules.server.podman;
in {
  options.modules.server.podman = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Podman.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable && cfgRoot.enable {
    networking.firewall.trustedInterfaces = [ "podman0" ];
    virtualisation = {
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        autoPrune.enable = true;
        defaultNetwork.settings = {
          dns_enabled = true;
        };
      };
    };
  };
}
