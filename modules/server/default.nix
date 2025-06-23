{ lib, helpers, ... }:

with lib; {
  options.modules.server = {
    enable = mkOption {
      default = false;
      example = true;
      description = "Whether to enable Server options.";
      type = types.bool;
    };
  };

  imports = [
    ./sshd.nix
    ./tailscale.nix
    ./vaultwarden.nix
    ./hd-idle.nix
    ./caddy.nix
    ./jellyfin.nix
    ./home-assistant.nix
    ./podman.nix
    ./macos.nix
  ];
}
