{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.ssh;
  target = "${config.home.homeDirectory}/.ssh/authorized_keys_home";
  marker = "# Managed by Home Manager: modules.ssh.authorizedKeys";
  keysFile = pkgs.writeText "home-authorized-keys" (optionalString (cfg.authorizedKeys != [ ])
    (marker + "\n" + concatStringsSep "\n" cfg.authorizedKeys + "\n"));
  installKeys = pkgs.writeShellScript "home-authorized-keys" ''
    set -euo pipefail
    target=$1
    source=$2
    tools=${pkgs.coreutils}/bin
    marker=${escapeShellArg marker}
    managed=false
    if [[ -f "$target" && ! -L "$target" ]] && [[ $("$tools/head" -n 1 -- "$target") == "$marker" ]]; then
      managed=true
    fi
    if [[ -s "$source" && ( -e "$target" || -L "$target" ) && $managed != true ]]; then
      echo "Refusing to replace unmanaged SSH keys file: $target" >&2
      exit 1
    fi
    [[ ''${3-} != check ]] || exit 0
    if [[ -s "$source" ]]; then
      directory=$("$tools/dirname" -- "$target")
      "$tools/install" -d -m 0700 -- "$directory"
      temporary=$("$tools/mktemp" "$directory/.authorized_keys_home.XXXXXX")
      trap '"$tools/rm" -- "$temporary"' EXIT
      "$tools/install" -m 0600 -- "$source" "$temporary"
      "$tools/mv" -T -- "$temporary" "$target"
      trap - EXIT
    elif [[ $managed == true ]]; then
      "$tools/rm" -- "$target"
    fi
  '';
  installArguments = "${installKeys} ${escapeShellArg target} ${keysFile}";
in
{
  options.modules.ssh.authorizedKeys = mkOption {
    default = [ ];
    apply = unique;
    type = types.listOf (types.strMatching "[^\r\n]+");
    description = ''
      Complete authorized_keys entries, including optional restrictions, merged
      into ~/.ssh/authorized_keys_home. Activation manages a regular 0600 file
      for OpenSSH StrictModes; an empty list removes the managed file.
    '';
  };

  config = {
    assertions = [{
      assertion = all (file: !file.enable || !(elem file.target [ ".ssh/authorized_keys_home" target ]))
        (attrValues config.home.file);
      message = "Use modules.ssh.authorizedKeys instead of home.file to manage .ssh/authorized_keys_home.";
    }];

    home.activation.checkAuthorizedKeys = hm.dag.entryBefore [ "writeBoundary" ] ''
      ${installArguments} check
    '';
    home.activation.authorizedKeys = hm.dag.entryAfter [ "linkGeneration" ] ''
      run ${installArguments}
    '';

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";

        Compression = true;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 5;
        IPQoS = "none";
        SetEnv.TERM = "xterm";
      };
    };
  };
}
