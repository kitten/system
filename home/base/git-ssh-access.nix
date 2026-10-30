{ lib, config, pkgs, ... }:

let
  cfg = config.modules.git;
  access = cfg.sshAccess;
  hooks = pkgs.runCommand "git-ssh-empty-hooks" { } "mkdir -p $out";
  helper = pkgs.writers.writeRustBin "git-ssh-access" {
    rustcArgs = [ "--edition=2024" "-C" "opt-level=s" ];
  } (builtins.readFile ./git-ssh-access.rs);
  command = lib.escapeShellArgs [
    "${helper}/bin/git-ssh-access"
    config.home.homeDirectory
    cfg.directory
    "${pkgs.git}/bin/git"
    (toString hooks)
    (lib.boolToString access.allowPush)
  ];
  quotedCommand = lib.replaceStrings [ "\\" "\"" ] [ "\\\\" "\\\"" ] command;
in {
  options.modules.git.sshAccess = {
    enable = lib.mkEnableOption "Git-only SSH access to repositories beneath modules.git.directory";

    authorizedKeys = lib.mkOption {
      default = [ ];
      apply = lib.unique;
      type = lib.types.listOf (lib.types.strMatching "(ssh-[^ \r\n]+|ecdsa-[^ \r\n]+|sk-[^ \r\n]+) [A-Za-z0-9+/=]+( [^\r\n]*)?");
      description = ''
        Public SSH keys granted Git-only access to repositories beneath modules.git.directory.
        Repository paths retain normal SSH semantics: relative to the account's
        home directory, or absolute. Paths are validated, never remapped.
        Resolved repository paths inside dot directories beneath the Git root
        are excluded.
        Do not include authorized_keys options. These restrictions apply to OpenSSH;
        Tailscale SSH has separate authorization and does not enforce them.
        Entries are merged into modules.ssh.authorizedKeys.
      '';
    };

    allowPush = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Whether these keys may push to existing repositories. Checked-out branches remain protected and server-side hooks are disabled.";
    };
  };

  config = lib.mkIf (cfg.enable && access.enable) {
    modules.ssh.authorizedKeys = map
      (key: ''restrict,command="${quotedCommand}" ${key}'') access.authorizedKeys;
  };
}
