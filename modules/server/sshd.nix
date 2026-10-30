{ lib, config, user, helpers, ... }:

with lib;
let
  cfg = config.modules.server;
  agentUsers = attrNames (filterAttrs (_: account: account.enable) config.modules.agents);
  allowedUsers = unique cfg.sshd.allowUsers;
  loginKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgNlwxQFRcZjnOyoNQ9HDkhGrESU8J5fwd0HeF6CiYg"
  ];
  sshSettings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    MaxAuthTries = 3;
    LoginGraceTime = 30;
    MaxSessions = 5;
    ClientAliveInterval = 60;
    ClientAliveCountMax = 3;
    AllowAgentForwarding = false;
    AllowTcpForwarding = false;
    X11Forwarding = false;
    AllowStreamLocalForwarding = false;
    AllowUsers = allowedUsers;
  };
  renderSettings = generators.toKeyValue {
    mkKeyValue = name: value: "${name} ${
      if isBool value then (if value then "yes" else "no")
      else if isList value then concatStringsSep " " value
      else toString value
    }";
  };
in {
  options.modules.server.sshd = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable the SSH server.";
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

    users.users.${user}.openssh.authorizedKeys.keys = loginKeys;

    services.openssh = {
      enable = true;
    } // helpers.darwinAttrs {
      extraConfig = renderSettings sshSettings + ''
        AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys_home
      '';
    } // helpers.linuxAttrs {
      authorizedKeysFiles = [ "%h/.ssh/authorized_keys_home" ];
      openFirewall = mkDefault true;
      ports = [ 22 ];
      settings = sshSettings // {
        MaxStartups = "10:30:60";
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
