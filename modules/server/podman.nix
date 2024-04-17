{ ... }:

{
  networking.firewall.trustedInterfaces = [ "podman0" ];

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };
}
