{ lib, config, hostname, ... }:

with lib;
let
  cfgRoot = config.modules.server;
  cfgRouter = config.modules.router;
  cfg = config.modules.server.tailscale;
in {
  options.modules.server.tailscale = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Tailscale.";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable && cfgRoot.enable) {
    networking = {
      domain = "fable-pancake.ts.net";
      search = [ "fable-pancake.ts.net" ];
      firewall.trustedInterfaces = [ "tailscale0" ];
      hosts."${cfgRouter.address}" = mkIf cfgRouter.enable [ "${hostname}.fable-pancake.ts.net" hostname ];
    };

    age.secrets."tailscale" = {
      symlink = true;
      path = "/run/secrets/tailscale";
      file = ./encrypt/tailscale.age;
    };

    services.tailscale = {
      enable = true;
      useRoutingFeatures = if cfgRouter.enable then "server" else "none";
      extraUpFlags = if cfgRouter.enable
        then [ "--advertise-exit-node" "--ssh" "--accept-dns=false" ]
        else [ "--ssh" ];
      extraDaemonFlags = [ "--no-logs-no-support" ];
      authKeyFile = "/run/secrets/tailscale";
    };

    systemd.services.tailscaled.serviceConfig.Environment = [ "TS_DEBUG_DISABLE_PORTLIST=true" ];
  };
}
