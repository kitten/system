{ helpers, ... }:

helpers.linuxAttrs {
  imports = [
    ./services.nix
    ./session.nix
    ./xdg.nix
  ];
}
