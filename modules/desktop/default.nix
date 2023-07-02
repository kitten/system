{ helpers, ... }:

helpers.linuxAttrs {
  imports = [
    ./hardware.nix
    ./services.nix
    ./session.nix
    ./xdg.nix
  ];
}
