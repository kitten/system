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
      openFirewall = mkDefault true;
      ports = [ 22 ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        MaxAuthTries = 3;
        LoginGraceTime = 30;
      };
    };
  };
}
