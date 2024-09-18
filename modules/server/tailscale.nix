{ lib, config, hostname, ... }:

with lib;
let
  cfgRoot = config.modules.server;
  cfg = config.modules.server.tailscale;
in {
  options.modules.server.tailscale = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Tailscale.";
      type = types.bool;
    };

    authKeySecret = {
      description = "Age Secret of auth keyfile for Tailscale.";
      type = types.path;
    };
  };

  config = mkIf cfg.enable && cfgRoot.enable {
    networking = {
      domain = "fable-pancake.ts.net";
      firewall.trustedInterfaces = [ "tailscale0" ];
      hosts."10.0.0.1" = [ "${hostname}.fable-pancake.ts.net" hostname ];
    };

    age.secrets."tailscale" = {
      symlink = true;
      path = "/run/secrets/tailscale";
      file = cfg.authKeySecret;
    };

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      extraUpFlags = [ "--advertise-exit-node" "--ssh" ];
      extraDaemonFlags = [ "--no-logs-no-support" ];
      authKeyFile = "/run/secrets/tailscale";
    };

    systemd.services.tailscaled.serviceConfig.Environment = [ "TS_DEBUG_DISABLE_PORTLIST=true" ];
  };
}
