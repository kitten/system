{ helpers, ... }:

helpers.linuxAttrs {
  imports = [
    ./enshrouded-server.nix
  ];
}
