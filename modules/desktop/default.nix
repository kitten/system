{ helpers, ... }:

helpers.linuxAttrs {
  imports = [
    ./hardware.nix
    ./session.nix
  ];
}
