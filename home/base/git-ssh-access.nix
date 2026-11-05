{ lib, config, pkgs, ... }:

let
  cfg = config.modules.git;
  access = cfg.sshAccess;
  publicKeyType = lib.types.strMatching "(ssh-[^ \r\n]+|ecdsa-[^ \r\n]+|sk-[^ \r\n]+) [A-Za-z0-9+/=]+( [^\r\n]*)?";
  forwardingSsh = pkgs.writeShellScript "git-forward-ssh" ''
    exec ${helper}/bin/git-ssh-access transport ${lib.escapeShellArgs ([
      config.home.homeDirectory
      "${pkgs.openssh}/bin/ssh"
      "${pkgs.openssh}/bin/ssh-agent"
      (if access.forwarding.wrappedKey == null then "" else access.forwarding.wrappedKey)
    ] ++ access.authorizedKeys)} -- "$@"
  '';
  helper = pkgs.callPackage ./git-ssh-access/package.nix { };
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
    (toString forwardingSsh)
  ] + " " + lib.escapeShellArgs access.allowedPushPrefixes;
  quotedCommand = lib.replaceStrings [ "\\" "\"" ] [ "\\\\" "\\\"" ] command;
in {
  options.modules.git.sshAccess = {
    enable = lib.mkEnableOption "Git-only SSH access to repositories beneath modules.git.directory";

    authorizedKeys = lib.mkOption {
      default = [ ];
      apply = lib.unique;
      type = lib.types.listOf publicKeyType;
      description = ''
        Public SSH keys granted Git-only access to repositories beneath modules.git.directory.
        When forwarded, these identities must unlock the wrapped publication key;
        other forwarded identities authenticate directly using their own credentials.
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
      description = "Whether these keys may receive and forward branches in existing repositories. Checked-out branches remain protected; only the managed policy hook runs.";
    };

    forwarding = {
      # With the authorized agent key loaded in SSH_AUTH_SOCK:
      # git-ssh-access wrap < github-publication-key > github-publication-key.wrapped
      # Use wrap -i agent-identity.pub to select a key when the agent holds several.
      # Store the wrapped bundle in agenix and set wrappedKey to age.secrets.<name>.path.
      wrappedKey = lib.mkOption {
        default = null;
        type = lib.types.nullOr (lib.types.strMatching "/[^\n]+");
        description = "Agenix runtime path to the self-contained wrapped publication key. Its metadata identifies the approved source agent key.";
      };
    };

    allowedPushPrefixes = lib.mkOption {
      default = [ "@kitten/" "@kitten-agent/" ];
      type = lib.types.listOf (lib.types.strMatching "[A-Za-z0-9@._/-]+/");
      description = "Literal branch name prefixes writable through Git SSH access. An empty list denies all ref updates. Tags and deletions are always denied.";
    };
  };

  config = lib.mkIf (cfg.enable && access.enable) {
    home.packages = [ helper ];
    assertions = [{
      assertion = access.forwarding.wrappedKey == null
        || !(lib.hasPrefix "/nix/store/" access.forwarding.wrappedKey);
      message = "git.sshAccess.forwarding.wrappedKey must be an agenix runtime path outside the Nix store.";
    }];
    modules.ssh.authorizedKeys = map
      (key: ''restrict,agent-forwarding,command="${quotedCommand}" ${key}'') access.authorizedKeys;
  };
}
