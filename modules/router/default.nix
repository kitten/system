{ helpers, ... }:

helpers.linuxAttrs {
  imports = [
    ./ntp.nix
    ./stubby.nix
    ./dnsmasq.nix
    ./nftables.nix
    ./miniupnpd.nix
    ./avahi.nix
  ];
}
