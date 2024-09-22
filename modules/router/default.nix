{ lib, helpers, ... }:

with lib; {
  options.modules.router = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Router options.";
      type = types.bool;
    };
  };

  config.modules.router = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
  imports = [
    ./network.nix
    ./timeserver.nix
    ./dnsOverTLS.nix
    ./dnsmasq.nix
    ./nftables.nix
    ./upnp.nix
    ./kernel.nix
  ];
}
