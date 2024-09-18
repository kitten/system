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

  config.modules.server = {
    enable = if helpers.isLinux then (mkDefault false) else (mkForce false);
  };
} // helpers.linuxAttrs {
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
