{ lib, config, user, helpers, ... }:

with lib;
let
  cfg = config.modules.server;
in {
  options.modules.server.sshd = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable SSH server.";
      type = types.bool;
    };
  };

  config = mkIf cfg.sshd.enable {
    users.users."${user}".openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgNlwxQFRcZjnOyoNQ9HDkhGrESU8J5fwd0HeF6CiYg"
    ];

    services.openssh = {
      enable = true;
    } // helpers.linuxAttrs {
      openFirewall = mkDefault (!config.modules.router.enable);
      ports = [ 22 2222 ];
    };
  };
}
