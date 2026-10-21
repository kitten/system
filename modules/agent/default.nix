{ lib, config, pkgs, helpers, user, ... }:

with lib;
let
  accounts = filterAttrs (_: account: account.enable) config.modules.agents;
  uids = mapAttrsToList (_: account: account.uid) accounts;
  encryptedFile = types.addCheck types.path (file: hasSuffix ".age" (toString file));

  accountType = types.submodule ({ name, ... }: {
    options = {
      enable = mkEnableOption "the ${name} agent account";

      uid = mkOption {
        description = "Unique UID of this agent account.";
        type = types.ints.positive;
      };

      homeDirectory = mkOption {
        default = "${if helpers.isDarwin then "/Users" else "/home"}/${name}";
        readOnly = true;
        description = "Home directory of this account.";
        type = types.str;
      };

      git = {
        name = mkOption {
          default = "kitten-${name}";
          description = "Git author name.";
          type = types.str;
        };
        email = mkOption {
          example = "phil+agent@kitten.sh";
          description = "Git author email of the agent's GitHub account.";
          type = types.str;
        };
      };

      signing = {
        enable = mkEnableOption "SSH commit and tag signing";
        keyFile = mkOption {
          default = null;
          description = "Optional encrypted signing key (.age); defaults to the authentication key.";
          type = types.nullOr encryptedFile;
        };
      };

      secrets = genAttrs [ "env" "ssh" ] (kind: mkOption {
        default = null;
        description = "Optional encrypted ${kind} credentials for ${name}.";
        type = types.nullOr encryptedFile;
      });

      developerGroup = mkOption {
        default = helpers.isDarwin;
        description = "Whether to add the account to macOS's _developer group.";
        type = types.bool;
      };

      home = mkOption {
        default = { };
        description = "Home Manager configuration; accepts imports and options from ./home modules.";
        type = types.deferredModule;
      };

    };
  });

  mkSecrets = name: account: let
    secret = file: {
      inherit file;
      group = if helpers.isDarwin then "staff" else name;
      owner = name;
      mode = "0400";
    };
  in optional (account.secrets.env != null)
    (nameValuePair "${name}.env" (secret account.secrets.env))
    ++ optional (account.secrets.ssh != null)
    (nameValuePair "${name}-ssh" (secret account.secrets.ssh))
    ++ optional (account.signing.enable && account.signing.keyFile != null)
    (nameValuePair "${name}-signing" (secret account.signing.keyFile));

  mkUser = name: account: {
    uid = account.uid;
    home = account.homeDirectory;
    createHome = true;
    shell = pkgs.zsh;
    description = "Agent (${name})";
  } // helpers.darwinAttrs {
    gid = 20;
    isHidden = true;
  } // helpers.linuxAttrs {
    isSystemUser = true;
    group = name;
  };

  mkHome = name: account: {
    imports = [ ../../home/agent account.home ];
    modules.agent = {
      enable = true;
      inherit (account.git) name email;
      sshKey = if account.secrets.ssh == null then null else config.age.secrets."${name}-ssh".path;
      tokenEnvFile = if account.secrets.env == null then null else config.age.secrets."${name}.env".path;
      signing = {
        inherit (account.signing) enable;
      } // optionalAttrs (account.signing.enable && account.signing.keyFile != null) {
        key = config.age.secrets."${name}-signing".path;
      };
    };
  };
in {
  options.modules.agents = mkOption {
    default = { };
    description = "Named agent accounts and their Home Manager configurations.";
    type = types.attrsOf accountType;
  };

  config = mkMerge [
    {
      assertions = [{
        assertion = length uids == length (unique uids);
        message = "modules.agents: enabled accounts must have distinct UIDs.";
      }] ++ mapAttrsToList (name: _: {
        assertion = name != user && builtins.match "[a-z_][a-z0-9_-]*" name != null;
        message = "modules.agents.${name}: use a valid username distinct from the primary user.";
      }) accounts;

      nix.settings.allowed-users = attrNames accounts;
      users.users = mapAttrs mkUser accounts;
      home-manager.users = mapAttrs mkHome accounts;
      age.secrets = listToAttrs (concatLists (mapAttrsToList mkSecrets accounts));
    }

    (helpers.darwinAttrs {
      users.knownUsers = attrNames accounts;
      system.activationScripts.postActivation.text = mkAfter (concatStrings
        (mapAttrsToList (name: account: optionalString account.developerGroup ''
          dseditgroup -o edit -a ${name} -t user _developer 2>/dev/null || true
        '') accounts));
    })

    (helpers.linuxAttrs {
      users.groups = mapAttrs (_: _: { }) accounts;
    })
  ];
}
