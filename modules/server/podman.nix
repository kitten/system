{ lib, config, user, pkgs, ... }:

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
        extraPackages = with pkgs; [ podman-compose ];
        defaultNetwork.settings = {
          dns_enabled = true;
        };
      };
    };

    environment.systemPackages = with pkgs; [ docker-compose ];
    users.users."${user}".extraGroups = [ "podman" ];

    environment.extraInit = ''
      if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
        export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
      fi
    '';

    boot.kernel.sysctl = mkIf cfg.tweakKernel {
      "kernel.unprivileged_userns_clone" = true;
      "net.ipv4.ip_unprivileged_port_start" = "80";
      "net.ipv4.ping_group_range" = "0 65536";
    };
  };
}
