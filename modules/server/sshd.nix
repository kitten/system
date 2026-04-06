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

    allowUsers = mkOption {
      default = [ user ];
      description = "Users allowed to log in via SSH.";
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.sshd.enable {
    users.users."${user}".openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgNlwxQFRcZjnOyoNQ9HDkhGrESU8J5fwd0HeF6CiYg"
    ];

    systemd.services.sshd.serviceConfig = helpers.linuxAttrs {
      MemoryMax = "8G";
      MemoryHigh = "6G";
      CPUWeight = 80;
      TasksMax = 256;
    };

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
        MaxSessions = 5;
        MaxStartups = "10:30:60";
        ClientAliveInterval = 60;
        ClientAliveCountMax = 3;
        AllowAgentForwarding = false;
        AllowTcpForwarding = false;
        X11Forwarding = false;
        AllowStreamLocalForwarding = false;
        AllowUsers = cfg.sshd.allowUsers;
      };
    };
  };
}
