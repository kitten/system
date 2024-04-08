{ user, ... }:

{
  networking = {
    domain = "fable-pancake.ts.net";
    firewall.trustedInterfaces = [ "tailscale0" ];
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
}
