{ lib, config, user, ... }:

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

    tweakKernel = mkOption {
      default = cfg.enable;
      description = "Whether to tweak kernel configuration";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfgRoot.enable) {
    networking.firewall.trustedInterfaces = [ "podman0" ];
    virtualisation = {
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        dockerCompat = true;
        autoPrune.enable = true;
        defaultNetwork.settings = {
          dns_enabled = true;
        };
      };
    };

    users.users."${user}".extraGroups = [ "podman" ];

    boot.kernel.sysctl = mkIf cfg.tweakKernel {
      "kernel.unprivileged_userns_clone" = true;
      "net.ipv4.ping_group_range" = "0 65536";
    };
  };
}
