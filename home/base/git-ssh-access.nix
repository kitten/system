{ lib, config, pkgs, ... }:

let
  cfg = config.modules.git;
  access = cfg.sshAccess;
  helper = pkgs.writers.writeRustBin "git-ssh-access" {
    rustcArgs = [ "--edition=2024" "-C" "opt-level=s" ];
  } (builtins.readFile ./git-ssh-access.rs);
  preReceive = pkgs.writeShellScript "git-ssh-pre-receive" ''
    exec ${helper}/bin/git-ssh-access check ${pkgs.git}/bin/git ${lib.escapeShellArgs access.allowedPushPrefixes}
  '';
  hooks = pkgs.runCommand "git-ssh-hooks" { } ''
    mkdir -p $out
    ln -s ${preReceive} $out/pre-receive
  '';
  command = lib.escapeShellArgs [
    "${helper}/bin/git-ssh-access"
    config.home.homeDirectory
    cfg.directory
    "${pkgs.git}/bin/git"
    (toString hooks)
    (lib.boolToString access.allowPush)
    "${pkgs.openssh}/bin/ssh"
  ] + " " + lib.escapeShellArgs access.allowedPushPrefixes;
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
      description = "Whether these keys may receive and promote branches in existing repositories. Checked-out branches remain protected; only the managed policy hook runs.";
    };

    allowedPushPrefixes = lib.mkOption {
      default = [ "@kitten/" "@kitten-agent/" ];
      type = lib.types.listOf (lib.types.strMatching "[A-Za-z0-9@._/-]+/");
      description = "Literal branch name prefixes writable through Git SSH access. An empty list denies all ref updates. Tags and deletions are always denied.";
    };
  };

  config = lib.mkIf (cfg.enable && access.enable) {
    modules.ssh.authorizedKeys = map
      (key: ''restrict,command="${quotedCommand}" ${key}'') access.authorizedKeys;
  };
}
