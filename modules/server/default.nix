{ helpers, ... }:

helpers.linuxAttrs {
  imports = [
    ./sshd.nix
    ./tailscale.nix
    ./vaultwarden.nix
    ./hd-idle.nix
    ./caddy.nix
    ./jellyfin.nix
    ./home-assistant.nix
    ./podman.nix
  ];
}
