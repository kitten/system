{ lib, config, user, helpers, ... }:

with lib;
let
  cfg = config.modules.server;
  agentUsers = attrNames (filterAttrs (_: account: account.enable) config.modules.agents);
  allowedUsers = unique cfg.sshd.allowUsers;
  loginKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgNlwxQFRcZjnOyoNQ9HDkhGrESU8J5fwd0HeF6CiYg"
  ];
in {
  options.modules.server.sshd = {
    enable = mkOption {
      default = cfg.enable;
      example = true;
      description = "Whether to enable SSH server.";
      type = types.bool;
    };

    allowUsers = mkOption {
      default = [ ];
      description = "Local usernames allowed to log in via SSH; patterns and user@host entries are not supported.";
      type = types.listOf (types.strMatching "[a-zA-Z_][a-zA-Z0-9_-]*");
    };
  };

  config = mkIf cfg.sshd.enable ({
    assertions = [{
      assertion = allowedUsers != [ ];
      message = "modules.server.sshd.allowUsers must not be empty when SSH is enabled.";
    }];

    modules.server.sshd.allowUsers = [ user ] ++ agentUsers;

    # The operator's key allows incoming access to personal and agent accounts.
    # Agents keep their own outgoing Git credentials separately.
    users.users = genAttrs (unique ([ user ] ++ agentUsers)) (_: {
      openssh.authorizedKeys.keys = loginKeys;
    });

    services.openssh = {
      enable = true;
    } // helpers.darwinAttrs {
      extraConfig = ''
        AllowUsers ${concatStringsSep " " allowedUsers}
      '';
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
        AllowUsers = allowedUsers;
      };
    };
  } // helpers.darwinAttrs {
    system.activationScripts.users.text = mkAfter ''
      # An absent SSH access group means macOS allows all users.
      if /usr/bin/dscl . -read /Groups/com.apple.access_ssh >/dev/null 2>&1; then
        ${concatMapStringsSep "\n" (name: ''
          /usr/sbin/dseditgroup -o edit -a ${escapeShellArg name} -t user com.apple.access_ssh
        '') allowedUsers}
      fi
    '';
  } // helpers.linuxAttrs {
    systemd.services.sshd.serviceConfig = {
      MemoryMax = "8G";
      MemoryHigh = "6G";
      CPUWeight = 80;
      TasksMax = 256;
    };
  });
}
