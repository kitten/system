{ user, ... }:

{
  networking = {
    domain = "fable-pancake.ts.net";
    firewall.trustedInterfaces = [ "tailscale0" ];
    hosts."10.0.0.1" = [ "cola.fable-pancake.ts.net" "cola" ];
  };

  age.secrets."tailscale" = {
    symlink = true;
    path = "/run/secrets/tailscale";
    file = ./encrypt/tailscale.age;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraUpFlags = [ "--advertise-exit-node" "--ssh" ];
    extraDaemonFlags = [ "--no-logs-no-support" ];
    authKeyFile = "/run/secrets/tailscale";
  };

  systemd.services.tailscaled.serviceConfig.Environment = [ "TS_DEBUG_DISABLE_PORTLIST=true" ];
}
