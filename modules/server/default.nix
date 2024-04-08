{ helpers, ... }:

helpers.linuxAttrs {
  imports = [
    ./sshd.nix
    ./tailscale.nix
    ./vaultwarden.nix
    ./hd-idle.nix
    ./caddy.nix
    ./plex.nix
    ./home-assistant.nix
  ];
}
